/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The host app renderer.
 */

import Metal
import MetalKit
import ARKit
import Foundation
import UIKit

final class Renderer {
    // START||STOP BUTTON 활성 여부
    public var isRecording = false;
    // 저장할 폴더 경로
    public var currentFolder = ""
    // 매 n번째 프레임을 선택함
    public var pickFrames = 1 // 새로운 프레임 중 1/5를 저장하도록 기본 설정
    //현재 프레임 index
    public var currentFrameIndex = 0;
    // Task delegate for informing ViewController of tasks
    public weak var delegate: TaskDelegate?
    
    // 저장할 최대 포인트 개수
    private let maxPoints = 500_000
    // grid상 샘플링 포인트의 개수(grid에서 얼마나 많은 지점에서 데이터를 수집하거나, 측정하는지)
    private let numGridPoints = 500
    // Particle's size in pixels
    private let particleSize: Float = 10
    // 디바이스 가로 방향 회전상태로 설정
    private let orientation = UIInterfaceOrientation.landscapeRight
    // Camera's threshold values for detecting when the camera moves so that we can accumulate the points
    private let cameraRotationThreshold = cos(2 * .degreesToRadian) //카메라 회전 감지 임계값
    private let cameraTranslationThreshold: Float = pow(0.02, 2)   //카메라가 이동할 때 누적되는 포인트를 결정하기위해 사용되는 임계값 (meter-squared)
    // The max number of command buffers in flight
    //동시에 실행될 수 있는 최대 커맨드 버퍼 수
    private let maxInFlightBuffers = 3
    
    //AR Session에서 디바이스 카메라의 방향에 맞게 View Matrix를 회전시키는 4x4 변환 행렬을 생성하여 반환.
    private lazy var rotateToARCamera = Self.makeRotateToARCameraMatrix(orientation: orientation)
    private let session: ARSession
    
    // Metal objects and textures
    private let device: MTLDevice
    //Metal에서 사용될 Shader 코드를 컴파일한 라이브러리 객체
    private let library: MTLLibrary
    //RenderDestinationProvider 프로토콜 채택 객체
    private let renderDestination: RenderDestinationProvider
    //Metal에서 stencil testing과 depth testing에 사용되는 객체
    //stencil testing : 카메라 앞에 위치한 렌더링 개체가 화면에 나타나는 곳을 정의하기 위해 사용되는 기술.
    //depth testing : 렌더링 개체들을 depth buffer에 그리기 전에 카메라에 가까운 렌더링 개체들을 먼저 그리는 기술.
    private let relaxedStencilState: MTLDepthStencilState
    //수정private let depthStencilState: MTLDepthStencilState
    
    //GPU에서 실행할 명령을 전송하는 객체.
    //command buffer를 생성하면 생성된 command buffer에 command encoder를 추가하여 GPU에서 실행할 명령을 전달할 수 있음.
    //이를 통해 앱에서 GPU로 명령을 전송하여 그래픽스 또는 병렬처리 작업을 수행할 수 있음.
    private let commandQueue: MTLCommandQueue
    
    //unprojection기능을 수행하는 Metal Shader코드를 실행하는 데 필요한 pipe line state 객체
    private lazy var unprojectPipelineState = makeUnprojectionPipelineState()!
    //RGB기능을 수행하는 Metal Shader코드를 실행하는 데 필요한 pipe line state 객체
    private lazy var rgbPipelineState = makeRGBPipelineState()!
    
    // texture cache for captured image
    private lazy var textureCache = makeTextureCache()
    private var capturedImageTextureY: CVMetalTexture?
    private var capturedImageTextureCbCr: CVMetalTexture?
    private var depthTexture: CVMetalTexture?
    private var confidenceTexture: CVMetalTexture?
    
    // Multi-buffer rendering pipeline
    //동시에 실행 가능한 작업의 수를 제한하여 일정한 프레임 속도 유지.
    //현재 실행 중인 작업 수를 추적하고, 다음 프레임에서 새로운 작업이 시작되기 전에 현재 실행 중인 작업이 완료될 때까지 대기하도록 함.
    //동시에 실행 가능한 작업의 수를 제한하여 GPU부하를 줄이고 일정한 프레임 속도를 유지할 수 있음.
    private let inFlightSemaphore: DispatchSemaphore
    //현재 버퍼 index 정의
    private var currentBufferIndex = 0
    
    private var jsonCnt = 0; //json 파일의 개수
    
    // The current viewport size
    private var viewportSize = CGSize()
    // The grid of sample points
    //grid 포인트 좌표를 저장하는 버퍼??
    private lazy var gridPointsBuffer = MetalBuffer<Float2>(device: device,
                                                            array: makeGridPoints(),
                                                            index: kGridPoints.rawValue, options: [])
    
    // RGB buffer
    private lazy var rgbUniforms: RGBUniforms = {
        var uniforms = RGBUniforms()
        uniforms.radius = rgbRadius
        uniforms.viewToCamera.copy(from: viewToCamera)
        uniforms.viewRatio = Float(viewportSize.width / viewportSize.height)
        return uniforms
    }()
     
     
    private var rgbUniformsBuffers = [MetalBuffer<RGBUniforms>]()
    
    // Point Cloud buffer
    // This is not the point cloud data, but some parameters
    // pointcloud 추출 시 사용되는 변수??
    private lazy var pointCloudUniforms: PointCloudUniforms = {
        var uniforms = PointCloudUniforms()
        uniforms.maxPoints = Int32(maxPoints)
        uniforms.confidenceThreshold = Int32(confidenceThreshold)
        uniforms.particleSize = particleSize
        uniforms.cameraResolution = cameraResolution
        return uniforms
    }()
    
    //pointclouduniforms를 담은 배열??
    private var pointCloudUniformsBuffers = [MetalBuffer<PointCloudUniforms>]()
    
    // Particles buffer
    // Saves the point cloud data, filled by unprojectVertex func in Shaders.metal
    // Shaders.metal 파일의 unprojectVertex함수에 의해 채워진 point cloud를 담은 버퍼?
    private var particlesBuffer: MetalBuffer<ParticleUniforms>
    //현재 포인트 인덱스
    private var currentPointIndex = 0
    //현재 포인트 개수
    public var currentPointCount = 0
    
    // Camera data
    //현재 frame을 가져옴
    private var sampleFrame: ARFrame { session.currentFrame! }
    //현재 프레임의 해상도 저장
    private lazy var cameraResolution = Float2(Float(sampleFrame.camera.imageResolution.width), Float(sampleFrame.camera.imageResolution.height))
    //현재 프레임의 AR화면 좌표계에서 위치와 방향을 카메라 좌표계에서의 위치와 방향으로 변환하는데 사용되는 행렬(역행렬) ??
    private lazy var viewToCamera = sampleFrame.displayTransform(for: orientation, viewportSize: viewportSize).inverted()
    //마지막 프레임의 카메라의 변환 행렬(4x4) Roll, Pitch, Yaw 저장
    private lazy var lastCameraTransform = sampleFrame.camera.transform
    
    // interfaces
    //depth 신뢰도 임계값
    //less = 0 , medium = 1 , high = 2
    var confidenceThreshold = 2 {
        didSet {
            // apply the change for the shader
            // 변수가 바뀌면 pointCloudUnifoms의 confidenceThreshold 값 변경
            pointCloudUniforms.confidenceThreshold = Int32(confidenceThreshold)
        }
    }
    
    //디스플레이 색상 반경
    var rgbRadius: Float = 1.5 {
        didSet {
            // apply the change for the shader
            rgbUniforms.radius = rgbRadius
        }
    }
     
    
    //JSON FILE에 저장될 데이터 형식
    struct JsonFile: Codable{
        let local : String
        let filename : String
        var cnt : Int
        var pointcloud : [PointData]
    }
    
    struct PointData: Codable{
        var x : Float
        var y : Float
        var z : Float
    }
    
    private static var allPointCloud = ""
    private var cameraPose = ""
    
    public var client: TCPClient!
    private var tcp_ck = true
    private var tcp_ck2 = true
    private var tcp_cnt = 0
    private var tcp_mode = false
    private var local = "Hannuri_1F"
    private var jsonList : [String] = []
    
    //생성자 함수
    init(session: ARSession, metalDevice device: MTLDevice, renderDestination: RenderDestinationProvider) {
        self.session = session //세션 저장
        self.device = device //디바이스 저장
        self.renderDestination = renderDestination //프로토콜 저장
        
        library = device.makeDefaultLibrary()! //기본 라이브러리를 가져옴(기본 Shader code들)
        commandQueue = device.makeCommandQueue()! //GPU에서 실행할 command버퍼 저장
        
        // initialize our buffers
        //MetalBuffer를 초기화하여 append
        for _ in 0 ..< maxInFlightBuffers {
            //얘 버림
            rgbUniformsBuffers.append(.init(device: device, count: 1, index: 0))
            pointCloudUniformsBuffers.append(.init(device: device, count: 1, index: kPointCloudUniforms.rawValue))
        }
        particlesBuffer = .init(device: device, count: maxPoints, index: kParticleUniforms.rawValue)
        
        // rbg does not need to read/write depth
        //depth and stencil testing이 비활성화됨
        let relaxedStateDescriptor = MTLDepthStencilDescriptor()
        relaxedStencilState = device.makeDepthStencilState(descriptor: relaxedStateDescriptor)!
        
        //maxInFlightBuffers개수만큼 command를 실행하도록 강제함
        inFlightSemaphore = DispatchSemaphore(value: maxInFlightBuffers)
        
        
        //client = .init(shost: "192.168.64.2", sport: 5002)
        //client.start()
    }
    
    //viewport 사이즈 설정
    func drawRectResized(size: CGSize) {
        viewportSize = size
    }
    
    //캡처한 이미지 텍스처 업데이트
    
    private func updateCapturedImageTextures(frame: ARFrame) {
        // Create two textures (Y and CbCr) from the provided frame's captured image
        let pixelBuffer = frame.capturedImage
        guard CVPixelBufferGetPlaneCount(pixelBuffer) >= 2 else {
            return
        }
        
        capturedImageTextureY = makeTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .r8Unorm, planeIndex: 0)
        capturedImageTextureCbCr = makeTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .rg8Unorm, planeIndex: 1)
    }
     
    
    //depthMap Texture 업데이트
    private func updateDepthTextures(frame: ARFrame) -> Bool {
        guard let depthMap = frame.sceneDepth?.depthMap,
              let confidenceMap = frame.sceneDepth?.confidenceMap else {
            return false
        }
        
        depthTexture = makeTexture(fromPixelBuffer: depthMap, pixelFormat: .r32Float, planeIndex: 0)
        confidenceTexture = makeTexture(fromPixelBuffer: confidenceMap, pixelFormat: .r8Uint, planeIndex: 0)
        
        return true
    }
    
    //프레임의 카메라 정보 업데이트
    private func update(frame: ARFrame) {
        // frame dependent info
        let camera = frame.camera
        let cameraIntrinsicsInversed = camera.intrinsics.inverse
        let viewMatrix = camera.viewMatrix(for: orientation)
        let viewMatrixInversed = viewMatrix.inverse
        let projectionMatrix = camera.projectionMatrix(for: orientation, viewportSize: viewportSize, zNear: 0.001, zFar: 0)
        pointCloudUniforms.viewProjectionMatrix = projectionMatrix * viewMatrix
        pointCloudUniforms.localToWorld = viewMatrixInversed * rotateToARCamera
        pointCloudUniforms.cameraIntrinsicsInversed = cameraIntrinsicsInversed
        
        if(isRecording){
            let url2 = getDocumentsDirectory().appendingPathComponent(currentFolder, isDirectory: true).appendingPathComponent("Pose.txt")
            let poseTxt = "\(String(format: "%f", self.pointCloudUniforms.localToWorld.columns.3.x)) \(String(format: "%f", self.pointCloudUniforms.localToWorld.columns.3.y)) \(String(format: "%f", self.pointCloudUniforms.localToWorld.columns.3.z)) 255 0 0\n".data(using: .utf8)
            if let fileHandle = try? FileHandle(forWritingTo: url2){
                fileHandle.seekToEndOfFile()
                fileHandle.write(poseTxt!)
                fileHandle.closeFile()
            }
        }
    }
    
    //렌더링
    func draw() {
        guard let currentFrame = session.currentFrame,
              let renderDescriptor = renderDestination.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(), //새로운 명령어를 담을 수 있는 MTLCommandBuffer객체 생성
              //그래픽 렌더링 작업을 실행하기 위해 사용되는 객체. GPU에게 그래픽 렌더링 명령어를 전달하여 실제 그래픽 렌더링 작업을 실행함.
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {
            return
        }
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        commandBuffer.addCompletedHandler { [weak self] commandBuffer in
            if let self = self {
                self.inFlightSemaphore.signal()
            }
        }
        
        // update frame data
        update(frame: currentFrame)
        updateCapturedImageTextures(frame: currentFrame)
        
        // handle buffer rotating
        currentBufferIndex = (currentBufferIndex + 1) % maxInFlightBuffers
        pointCloudUniformsBuffers[currentBufferIndex][0] = pointCloudUniforms
        
        if shouldAccumulate(frame: currentFrame), updateDepthTextures(frame: currentFrame) {
            accumulatePoints(frame: currentFrame, commandBuffer: commandBuffer, renderEncoder: renderEncoder)
        }
        
        // check and render rgb camera image
        if rgbUniforms.radius > 0 {
            var retainingTextures = [capturedImageTextureY, capturedImageTextureCbCr]
            commandBuffer.addCompletedHandler { buffer in
                retainingTextures.removeAll()
            }
            rgbUniformsBuffers[currentBufferIndex][0] = rgbUniforms
            
            renderEncoder.setDepthStencilState(relaxedStencilState)
            renderEncoder.setRenderPipelineState(rgbPipelineState)
            renderEncoder.setVertexBuffer(rgbUniformsBuffers[currentBufferIndex])
            renderEncoder.setFragmentBuffer(rgbUniformsBuffers[currentBufferIndex])
            renderEncoder.setFragmentTexture(CVMetalTextureGetTexture(capturedImageTextureY!), index: Int(kTextureY.rawValue))
            renderEncoder.setFragmentTexture(CVMetalTextureGetTexture(capturedImageTextureCbCr!), index: Int(kTextureCbCr.rawValue))
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        }
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(renderDestination.currentDrawable!)
        commandBuffer.commit()
        
    }
    
    /// Save all particles to a point cloud file in ply format.
    func savePointCloud() {
        let url1 = getDocumentsDirectory().appendingPathComponent(currentFolder, isDirectory: true).appendingPathComponent("\(globalVariable).txt")

        
        if(self.currentPointCount > 0){
            Task.init(priority: .utility) {
                let start = Date()
                let tmpPointCount = 0+self.currentPointCount
                
                for i in 0..<self.currentPointCount{
                    while(self.particlesBuffer[i].position.x == 0.0){continue}
                }
                
                self.currentPointCount = 0
                self.currentPointIndex = 0
                self.currentBufferIndex = 0
                
                let fileHandle = try? FileHandle(forWritingTo: url1)
                fileHandle?.seekToEndOfFile()
                
                for i in 0..<tmpPointCount{
                    let point = self.particlesBuffer[i].position
                    let color = self.particlesBuffer[i].color
                    let red = color.x * 255.0
                    let green = color.y * 255.0
                    let blue = color.z * 255.0
                    
                    let pointCloudTxt = "\(String(format: "%.2f", point.x)) \(String(format: "%.2f", point.y)) \(String(format: "%.2f", point.z)) \(Int(red)) \(Int(green)) \(Int(blue))\n".data(using: .utf8)
                    
                    fileHandle?.write(pointCloudTxt!)
                    
                }
                fileHandle?.closeFile()
                
                print("Create File Elapsed time: \(-start.timeIntervalSinceNow) seconds")
                
                self.delegate?.didFinishTask()
                
            }
        }
    }
    
    public func save_Txt() {
        
        delegate?.didStartTask()
        Task.init(priority: .utility) {
            do {
                
                try await saveFile(content: "", filename: "\(globalVariable).txt", folder: currentFolder)
                try await saveFile(content: "", filename: "Pose.txt", folder: currentFolder)
                delegate?.didFinishTask()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func shouldAccumulate(frame: ARFrame) -> Bool {
        if (!isRecording) {
            return false
        }
        let cameraTransform = frame.camera.transform
        return currentPointCount == 0
        || dot(cameraTransform.columns.2, lastCameraTransform.columns.2) <= cameraRotationThreshold
        || distance_squared(cameraTransform.columns.3, lastCameraTransform.columns.3) >= cameraTranslationThreshold
    }
    
    /// Check if the current frame should be saved or dropped based on sampling rate configuration
    private func checkSamplingRate() -> Bool {
        currentFrameIndex += 1
        return currentFrameIndex % pickFrames == 0
    }
    
    private func accumulatePoints(frame: ARFrame, commandBuffer: MTLCommandBuffer, renderEncoder: MTLRenderCommandEncoder) {
        pointCloudUniforms.pointCloudCurrentIndex = Int32(currentPointIndex)
        
        var retainingTextures = [capturedImageTextureY, capturedImageTextureCbCr, depthTexture, confidenceTexture]
        commandBuffer.addCompletedHandler { buffer in
            retainingTextures.removeAll()
        }
        
        renderEncoder.setDepthStencilState(relaxedStencilState)
        renderEncoder.setRenderPipelineState(unprojectPipelineState)
        renderEncoder.setVertexBuffer(pointCloudUniformsBuffers[currentBufferIndex])
        renderEncoder.setVertexBuffer(particlesBuffer)
        renderEncoder.setVertexBuffer(gridPointsBuffer)
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(capturedImageTextureY!), index: Int(kTextureY.rawValue))
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(capturedImageTextureCbCr!), index: Int(kTextureCbCr.rawValue))
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(depthTexture!), index: Int(kTextureDepth.rawValue))
        renderEncoder.setVertexTexture(CVMetalTextureGetTexture(confidenceTexture!), index: Int(kTextureConfidence.rawValue))
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: gridPointsBuffer.count)
        
        currentPointIndex = (currentPointIndex + gridPointsBuffer.count) % maxPoints
        currentPointCount = min(currentPointCount + gridPointsBuffer.count, maxPoints)
        lastCameraTransform = frame.camera.transform
    }
}

// MARK: - Metal Helpers

private extension Renderer {
    func makeUnprojectionPipelineState() -> MTLRenderPipelineState? {
        guard let vertexFunction = library.makeFunction(name: "unprojectVertex") else {
            return nil
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.isRasterizationEnabled = false
        descriptor.depthAttachmentPixelFormat = renderDestination.depthStencilPixelFormat
        descriptor.colorAttachments[0].pixelFormat = renderDestination.colorPixelFormat
        
        return try? device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    
    func makeRGBPipelineState() -> MTLRenderPipelineState? {
        guard let vertexFunction = library.makeFunction(name: "rgbVertex"),
              let fragmentFunction = library.makeFunction(name: "rgbFragment") else {
            return nil
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.depthAttachmentPixelFormat = renderDestination.depthStencilPixelFormat
        descriptor.colorAttachments[0].pixelFormat = renderDestination.colorPixelFormat
        
        return try? device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    /// Makes sample points on camera image, also precompute the anchor point for animation
    func makeGridPoints() -> [Float2] {
        let gridArea = cameraResolution.x * cameraResolution.y
        let spacing = sqrt(gridArea / Float(numGridPoints))
        let deltaX = Int(round(cameraResolution.x / spacing))
        let deltaY = Int(round(cameraResolution.y / spacing))
        
        var points = [Float2]()
        for gridY in 0 ..< deltaY {
            let alternatingOffsetX = Float(gridY % 2) * spacing / 2
            for gridX in 0 ..< deltaX {
                let cameraPoint = Float2(alternatingOffsetX + (Float(gridX) + 0.5) * spacing, (Float(gridY) + 0.5) * spacing)
                
                points.append(cameraPoint)
            }
        }
        
        return points
    }
    
    func makeTextureCache() -> CVMetalTextureCache {
        // Create captured image texture cache
        var cache: CVMetalTextureCache!
        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        
        return cache
    }
    
    //텍스처 생성함수
    func makeTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        
        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
        
        if status != kCVReturnSuccess {
            texture = nil
        }
        
        return texture
    }
    
    static func cameraToDisplayRotation(orientation: UIInterfaceOrientation) -> Int {
        switch orientation {
        case .landscapeLeft:
            return 180
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return -90
        default:
            return 0
        }
    }
    
    static func makeRotateToARCameraMatrix(orientation: UIInterfaceOrientation) -> matrix_float4x4 {
        // flip to ARKit Camera's coordinate
        let flipYZ = matrix_float4x4(
            [1, 0, 0, 0],
            [0, -1, 0, 0],
            [0, 0, -1, 0],
            [0, 0, 0, 1] )
        
        let rotationAngle = Float(cameraToDisplayRotation(orientation: orientation)) * .degreesToRadian
        return flipYZ * matrix_float4x4(simd_quaternion(rotationAngle, Float3(0, 0, 1)))
    }
}
