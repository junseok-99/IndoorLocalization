//  SpaceInformationViewController.swift

import UIKit
import RealityKit
import ARKit
import RealityKit
import Foundation

class SpaceInformationViewController: UIViewController, ARSessionDelegate {
    private let startButton = UIButton()
    @IBOutlet var arView: ARView!
    let label = UILabel()
    
    private let orientation = UIInterfaceOrientation.landscapeRight
    private lazy var rotateToARCamera = Self.makeRotateToARCameraMatrix(orientation: orientation)
    public var isStarting = false
    let configuration = ARWorldTrackingConfiguration()
    
    var txt = ""
    var txt2 = ""
        
    var arr: [AnchorEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        
        startButton.setTitle("START", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 5
        startButton.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        arView.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.transform = CGAffineTransform(rotationAngle: -.pi * 3/2)

        label.text = "● \(globalSpace) \(globalFloor)"
        label.textColor = .white
        label.asColor(targetString: "●", color: .red)
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.transform = CGAffineTransform(rotationAngle: -.pi * 3/2)
        arView.addSubview(label)
        label.backgroundColor = .black
        
        NSLayoutConstraint.activate([
            startButton.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            startButton.leadingAnchor.constraint(equalTo: arView.leadingAnchor, constant: -70),
            startButton.widthAnchor.constraint(equalToConstant: 250),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            label.centerXAnchor.constraint(equalTo: startButton.centerXAnchor, constant: 250),
            label.centerYAnchor.constraint(equalTo: startButton.bottomAnchor, constant: -15)
        ])

        arView.environment.sceneUnderstanding.options = []
        
        // Turn on occlusion from the scene reconstruction's mesh.
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        // Turn on physics for the scene reconstruction's mesh.
        arView.environment.sceneUnderstanding.options.insert(.physics)
        

        // Display a debug visualization of the mesh.
        arView.debugOptions.insert(.showSceneUnderstanding)
        
        // For performance, disable render options that are not required for this app.
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        arView.automaticallyConfigureSession = false
        
        //configuration.sceneReconstruction = .meshWithClassification
        configuration.environmentTexturing = .automatic
        
        let matrix1 = simd_float4x4([
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, -0.25, -1.5, 1.0)
        ])
        
        let matrix2 = simd_float4x4([
            simd_float4(-0.98963255, -0.008600439, 0.1433651, 0.0),
            simd_float4(0.008427065, -0.99996287, -0.001816496, 0.0),
            simd_float4(0.1433754, -0.00058948185, 0.98966825, 0.0),
            simd_float4(1.52, 1.20, -3.9, 1.0)
        ])
        let matrix3 = simd_float4x4([
            simd_float4(-0.98963255, -0.008600439, 0.1433651, 0.0),
            simd_float4(0.008427065, -0.99996287, -0.001816496, 0.0),
            simd_float4(0.1433754, -0.00058948185, 0.98966825, 0.0),
            simd_float4(4.22, 1.20, -3.9, 1.0)
        ])
        let matrix4 = simd_float4x4([
            simd_float4(-0.98963255, -0.008600439, 0.1433651, 0.0),
            simd_float4(0.008427065, -0.99996287, -0.001816496, 0.0),
            simd_float4(0.1433754, -0.00058948185, 0.98966825, 0.0),
            simd_float4(7.63, 1.20, -3.9, 1.0)
        ])
        
        let resultAnchor = AnchorEntity(world: matrix1)
        let resultAnchor2 = AnchorEntity(world: matrix2)
        let resultAnchor3 = AnchorEntity(world: matrix3)
        let resultAnchor4 = AnchorEntity(world: matrix4)
        
        
        do {
            let modelEntity = try ModelEntity.load(named: "intro.usdz")
            //let modelEntity2 = try ModelEntity.load(named: "gg.usdz")
            resultAnchor.addChild(modelEntity)
            //resultAnchor2.addChild(modelEntity2)
            arr.append(resultAnchor)
            //arr.append(resultAnchor2)
            //arView.scene.addAnchor(resultAnchor, removeAfter: 3)
        } catch {
            print("Failed to load the model: \(error.localizedDescription)")
        }
        do {
            let modelEntity = try ModelEntity.load(named: "n202_1.usdz")
            resultAnchor2.addChild(modelEntity)
            let modelEntity2 = try ModelEntity.load(named: "n202_2.usdz")
            resultAnchor3.addChild(modelEntity2)
            let modelEntity3 = try ModelEntity.load(named: "n202_3.usdz")
            resultAnchor4.addChild(modelEntity3)
            //resultAnchor2.addChild(modelEntity2)
            arr.append(resultAnchor2)
            arr.append(resultAnchor3)
            arr.append(resultAnchor4)
            //arr.append(resultAnchor2)
            //arView.scene.addAnchor(resultAnchor, removeAfter: 3)
        } catch {
            print("Failed to load the model: \(error.localizedDescription)")
        }
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 라벨을 깜빡이게 하는 애니메이션
        UIView.animate(withDuration: 0.8, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.label.alpha = 0
        }, completion: nil)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let camera = frame.camera
        let viewMatrix = camera.viewMatrix(for: orientation)
        let viewMatrixInversed = viewMatrix.inverse
        let cameraInfo = viewMatrixInversed * rotateToARCamera
        let cameraPosition : simd_float3 = [cameraInfo.columns.3.x, cameraInfo.columns.3.y, cameraInfo.columns.3.z]
        
        let x = cameraPosition.x
        let y = cameraPosition.y
        let z = cameraPosition.z
        
        
        if(-1.54 <= x && x < 2.96 && -6.86 <= z && z <= 1.39){
            label.text = "● 구역 1"
        }
        else if(2.96 <= x && x < 5.84 && -6.41 <= z && z <= 2.15){
            label.text = "● 구역 2"
        }
        else if(5.84 <= x && x <= 8.59 && -5.75 <= z && z <= 2.88){
            label.text = "● 구역 3"
        }
        else{
            label.text = "● 구역벗어남"
        }
        
        if isStarting{
            label.asColor(targetString: "●", color: .green)
        }
        else{
            label.text = "● 스캔 중지"
            label.asColor(targetString: "●", color: .red)
        }
        
        
    }
    
    @objc
    func onButtonClick(_ sender: UIButton){
        if(sender != startButton){
            return
        }
        updateIsStarting(_isStarting: !isStarting)
    }
    
    func save(info: String, name: String){
        do{
            let url = getDocumentsDirectory().appendingPathComponent("Test", isDirectory: true).appendingPathComponent(name)
            try info.write(to: url, atomically: true, encoding: .utf8)
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func createDirectory(folder: String) {
        let path = getDocumentsDirectory().appendingPathComponent(folder)
        do
        {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        }
        catch let error as NSError
        {
            print("Unable to create directory \(error.debugDescription)")
        }
        
    }
    
    private func updateIsStarting(_isStarting: Bool) {
        isStarting = _isStarting
        if (isStarting){
            startButton.setTitle("PAUSE", for: .normal)
            startButton.backgroundColor = .systemRed
            arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
            arView.scene.addAnchor(arr[0], removeAfter: 5)
            for i in 1..<arr.count{
                arView.scene.addAnchor(arr[i])
            }
            
        } else {
            startButton.setTitle("START", for: .normal)
            startButton.backgroundColor = .systemBlue
            arView.session.pause()
            label.asColor(targetString: "●", color: .red)
        }
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
        
        let rotationAngle = Float(cameraToDisplayRotation(orientation: orientation)) * (Float.pi / 180)
        return flipYZ * matrix_float4x4(simd_quaternion(rotationAngle, Float3(0, 0, 1)))
    }
}

extension UILabel {
    func asColor(targetString: String, color: UIColor) {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: targetString)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        attributedText = attributedString
    }
}

extension Scene {
    // Add an anchor and remove it from the scene after the specified number of seconds.
/// - Tag: AddAnchorExtension
    func addAnchor(_ anchor: HasAnchoring, removeAfter seconds: TimeInterval) {
        
        self.addAnchor(anchor)
        
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { (timer) in
            self.removeAnchor(anchor)
        }
        
    }
}
