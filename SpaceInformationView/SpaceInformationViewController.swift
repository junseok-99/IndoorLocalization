//  SpaceInformationViewController.swift

import UIKit
import RealityKit
import ARKit
import RealityKit
import Foundation
import WebKit

class SpaceInformationViewController: UIViewController, ARSessionDelegate {
    private let startButton = UIButton()
    @IBOutlet var arView: ARView!
    let label = UILabel()
    let startLabel = UILabel()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private let orientation = UIInterfaceOrientation.landscapeRight
    private lazy var rotateToARCamera = Self.makeRotateToARCameraMatrix(orientation: orientation)
    public var isStarting = false
    let configuration = ARWorldTrackingConfiguration()
        
    var arr: [AnchorEntity] = []
    var info: Info = Info()
    
    let url = "http://ec2-15-165-85-195.ap-northeast-2.compute.amazonaws.com:8080"
    var spaceData = SpaceData()
    var arObjectData = ARObjectData()
    var arObjectCount = 0
    var spaceFlag = false
    var arObjectFlag = false
    var checkImage : UIImage?
    var imgView = UIImageView()
    
    struct SpaceData: Codable {
        let spaceInfo: [SpaceInfos]
        
        init() {
            self.spaceInfo = []
        }
    }
    
    struct SpaceInfos: Codable {
        let pos_name: String
        let x1: Float
        let x2: Float
        let z1: Float
        let z2: Float
    }
    
    struct ARObjectData: Codable {
        let arObjectInfo: [ARObjectInfos]
        
        init() {
            self.arObjectInfo = []
        }
    }
    
    struct ARObjectInfos: Codable {
        let file_name: String
        let x: Float
        let y: Float
        let z: Float
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
            // Create an indicator.
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.center = self.view.center
            activityIndicator.color = UIColor.white
        let transfrom = CGAffineTransform.init(scaleX: 3.5, y: 3.5)
        activityIndicator.transform = transfrom
            // Also show the indicator even when the animation is stopped.
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.white
            // Start animation.
            activityIndicator.stopAnimating()
            return activityIndicator }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(globalIdentifier)
        checkImage = UIImage(named: "\(globalIdentifier).jpg") ?? UIImage(named: "empty.jpg")
        deleteDirectory()
        createDirectory(folder: "usdzs")
        
        arView.session.delegate = self
        self.arView.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        startButton.setTitle("START", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 5
        startButton.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        startButton.isHidden = true
        arView.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false

        label.text = "데이터 불러오는중 ( 0 % )"
        label.textColor = .white
        label.asColor(targetString: "●", color: .red)
        label.font = UIFont.systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(label)
        label.backgroundColor = .black
        
        startLabel.text = "카메라 화면을 아래 이미지와 맞추고\n START를 눌러주세요!"
        startLabel.textAlignment = .center
        startLabel.numberOfLines = 2
        startLabel.textColor = .white
        startLabel.font = UIFont.boldSystemFont(ofSize: 18)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        startLabel.backgroundColor = .black
        arView.addSubview(startLabel)
        
        imgView.image = checkImage
        imgView.contentMode = .scaleToFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(imgView)
        
        imgView.isHidden = true
        startLabel.isHidden = true
        
        
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: arView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.widthAnchor.constraint(equalToConstant: 250),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            label.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            label.topAnchor.constraint(equalTo: arView.topAnchor, constant: 30),
            imgView.trailingAnchor.constraint(equalTo: arView.trailingAnchor, constant: -20),
            imgView.centerYAnchor.constraint(equalTo: startButton.centerYAnchor, constant: -15),
            imgView.heightAnchor.constraint(equalToConstant: 120),
            imgView.widthAnchor.constraint(equalToConstant: 250),
            startLabel.bottomAnchor.constraint(equalTo: imgView.topAnchor, constant: -10),
            startLabel.centerXAnchor.constraint(equalTo: imgView.centerXAnchor)
        ])

        arView.environment.sceneUnderstanding.options = []
        
        // Turn on occlusion from the scene reconstruction's mesh.
        //arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        // Turn on physics for the scene reconstruction's mesh.
        //arView.environment.sceneUnderstanding.options.insert(.physics)
        

        // Display a debug visualization of the mesh.
        arView.debugOptions.insert(.showSceneUnderstanding)
        
        // For performance, disable render options that are not required for this app.
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        arView.automaticallyConfigureSession = false
        
        //configuration.sceneReconstruction = .meshWithClassification
        configuration.environmentTexturing = .automatic
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appDelegate.shouldSupportAllOrientation = true
        
        UIView.animate(withDuration: 0.8, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.label.alpha = 0
        }, completion: nil)
        
        DispatchQueue.global(qos: .background).async {
            self.getSpaceInfo(globalIdentifier)

            DispatchQueue.main.async {
                self.label.text = "데이터 불러오는중 ( 30 % )"
                
                while (true) {
                    if (self.spaceFlag) {
                        break
                    }
                }
                DispatchQueue.global(qos: .background).async {
                    self.getARObjectInfo(globalIdentifier)
                    
                    while (true) {
                        if (self.arObjectFlag) {
                            break
                        }
                    }
                    DispatchQueue.main.async {
                        self.label.text = "데이터 불러오는중 ( 60 % )"
                        
                        DispatchQueue.global(qos: .background).async {
                            for i in 0..<self.arObjectData.arObjectInfo.count {
                                let fileName = self.arObjectData.arObjectInfo[i].file_name
                                if (!self.fileExists(fileName + ".usdz")) {
                                    print(i)
                                    self.fileDownload(fileName)
                                } else {
                                    self.arObjectCount -= 1
                                }
                            }
                            
                            while (true) {
                                if (self.arObjectCount == 0) {
                                    break
                                }
                            }

                            DispatchQueue.main.async {
                                self.label.text = "데이터 불러오는중 ( 85 % )"
                                        for i in 0..<self.arObjectData.arObjectInfo.count {
                                           do {
                                               let fileName = "\(self.arObjectData.arObjectInfo[i].file_name).usdz"
                                               let x = self.arObjectData.arObjectInfo[i].x
                                               let y = self.arObjectData.arObjectInfo[i].y
                                               let z = self.arObjectData.arObjectInfo[i].z
                                               let matrix = self.info.makePosMatrix(x: x, y: y, z: z)
                                               let resultAnchor = AnchorEntity(world: matrix)
                                               print(fileName)
                                               let modelEntity = try ModelEntity.load(contentsOf: getDocumentsDirectory().appendingPathComponent("usdzs", isDirectory: true).appendingPathComponent(fileName))
                                               resultAnchor.addChild(modelEntity)
                                               self.arr.append(resultAnchor)
                                           } catch {
                                               print("Failed to load the model: \(error.localizedDescription)")
                                            }
                                        }
                                        self.label.text = "데이터 불러오는중 ( 100 % )"
                                        self.activityIndicator.stopAnimating()
                                        self.label.text = "● \(globalSpace) \(globalFloor)"
                                        self.label.asColor(targetString: "●", color: .red)
                                        self.label.font = UIFont.systemFont(ofSize: 24)
                                        self.startButton.isHidden = false
                                        self.spaceFlag = false
                                        self.arObjectFlag = false
                            }
                        }
                    }
                }
            }
        }
        
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        imgView.isHidden = false
        startLabel.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.shouldSupportAllOrientation = false
        globalIdentifier = ""
        globalSpace = ""
        globalFloor = ""
        globalVariable = ""
    }

    func deleteDirectory() {
        let fileManager = FileManager.default
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let documentsDirectory = documentsDirectory {
            do {
                let usdzsDirectory = documentsDirectory.appendingPathComponent("usdzs", isDirectory: true)
                try fileManager.removeItem(at: usdzsDirectory)
                
                print("Document 디렉터리 삭제 완료.")
            } catch {
                print("Document 디렉터리 삭제 실패: \(error)")
            }
        }
    }

    
    func fileExists(_ fileName: String) -> Bool {
        let fileManager = FileManager.default
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let usdzsDirectory = documentsDirectory.appendingPathComponent("usdzs", isDirectory: true)
                let usdzFilePath = usdzsDirectory.appendingPathComponent(fileName)
                
                return fileManager.fileExists(atPath: usdzFilePath.path)
            }
            return false
    }
    
    func fileDownload(_ fileName: String) {
        
        let usdzName = getDocumentsDirectory().appendingPathComponent("usdzs", isDirectory: true).appendingPathComponent("\(fileName).usdz")
        
        let urlPath = "/info/download?file_name=\(fileName)"
        let finalUrl = url + urlPath

        
        if let imageUrl = URL(string: finalUrl) {
            
            URLSession.shared.downloadTask(with: imageUrl) { (tempFileUrl, response, error) in
                
                
                if let usdzTempFileUrl = tempFileUrl {
                    do {
                        // Write to file
                        let usdzData = try Data(contentsOf: usdzTempFileUrl)
                        try usdzData.write(to: usdzName)
                        self.arObjectCount -= 1
                    } catch {
                        print("Create File Error")
                    }
                }
            }.resume()
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
        
        if (isStarting) {
            for i in 0...spaceData.spaceInfo.count {
                if (i < spaceData.spaceInfo.count 
                    && spaceData.spaceInfo[i].x1 <= x
                    && x <= spaceData.spaceInfo[i].x2
                    && spaceData.spaceInfo[i].z1 <= z
                    && z <= spaceData.spaceInfo[i].z2) {
                    
                    label.text = "● \(spaceData.spaceInfo[i].pos_name)"
                    break
                }
                label.text = "● 구역벗어남"
            }
        }
        
        if isStarting {
            label.asColor(targetString: "●", color: .green)
        }
        else{
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
            imgView.isHidden = true
            startLabel.isHidden = true
            arView.session.pause()
            arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
            arView.scene.addAnchor(arr[0], removeAfter: 5)
            for i in 1..<arr.count{
                arView.scene.addAnchor(arr[i])
            }
            
        } else {
            imgView.isHidden = false
            startLabel.isHidden = false
            startButton.setTitle("START", for: .normal)
            startButton.backgroundColor = .systemBlue
            label.asColor(targetString: "●", color: .red)
        }
    }
    
    private func getSpaceInfo(_ spaceName: String) {
        
        let path = "/info/space?spaceName=\(spaceName)"
        print(path)
        let finalUrl = url + path
        
        if let url = URL(string: finalUrl){
                    
                var request = URLRequest.init(url: url)
                
                request.httpMethod = "GET"
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    
                URLSession.shared.dataTask(with: request){ (data, response, error) in
                        
                    if let error = error {
                            print("Error: \\(error.localizedDescription)")
                            return
                        }

                        guard let data = data else {
                            print("No data received")
                            return
                        }

                    
                        do {
                            self.spaceData = try JSONDecoder().decode(SpaceData.self, from: data)
                            self.spaceFlag = true
                            } catch let error {
                                print("Error: JSONS ERROR!!")
                            }
                }.resume() //URLSession - end
                    
            }
    }
    
    private func getARObjectInfo(_ spaceName: String) {
        
        let path = "/info/arObject?spaceName=\(spaceName)"
        let finalUrl = url + path
        
        if let url = URL(string: finalUrl){
                    
                var request = URLRequest.init(url: url)
                
                request.httpMethod = "GET"
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    
                URLSession.shared.dataTask(with: request){ (data, response, error) in
                        
                    if let error = error {
                            print("Error: \\(error.localizedDescription)")
                            return
                        }

                        guard let data = data else {
                            print("No data received")
                            return
                        }

                    
                        do {
                            self.arObjectData = try JSONDecoder().decode(ARObjectData.self, from: data)
                            self.arObjectCount = self.arObjectData.arObjectInfo.count
                            self.arObjectFlag = true
                            } catch let error {
                                print("Error: ARObject ERROR!!")
                            }
                }.resume() //URLSession - end
                    
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
