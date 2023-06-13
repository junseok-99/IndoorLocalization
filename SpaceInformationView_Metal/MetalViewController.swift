//
//  SpaceInformationView_MetalViewController.swift
//  SceneDepthPointCloud
//
//  Created by 유용상 on 2023/05/19.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import ARKit

class MetalViewController: UIViewController, ARSessionDelegate, MTKViewDelegate {
    
    
    private let isUIEnabled = true
    private let confidenceControl = UISegmentedControl(items: ["Low", "Medium", "High"])
    //private let rgbRadiusSlider = UISlider()
    private let pickFramesSlider = UISlider()
    private let recordButton = UIButton()
    private let textLabel = UILabel()
    private let tLabel = UILabel()
    
    private var isRecording = false
    
    private var taskNum = 0;
    private var completedTaskNum = 0;
    
    private let session = ARSession()
    private var renderer: Renderer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 3/2)
        self.view.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)

        //Metal 지원불가 모델이면 out
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        session.delegate = self
        
        // Set the view to use the default device
        if let view = view as? MTKView {
            view.device = device
            
            view.backgroundColor = UIColor.clear
            // we need this to enable depth test
            view.depthStencilPixelFormat = .depth32Float
            view.contentScaleFactor = 1
            view.delegate = self
            
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: device, renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
            renderer.delegate = self
        }
        
        // Confidence control (depth 신뢰도 UI설정)
        confidenceControl.backgroundColor = .white
        //confidenceControl.selectedSegmentIndex = renderer.confidenceThreshold
        confidenceControl.addTarget(self, action: #selector(viewValueChanged), for: .valueChanged)

        // Pick every x Frames control (pickFrameSlider UI설정)
        pickFramesSlider.minimumValue = 1
        pickFramesSlider.maximumValue = 50
        pickFramesSlider.isContinuous = true
        pickFramesSlider.value = Float(renderer.pickFrames)
        pickFramesSlider.addTarget(self, action: #selector(viewValueChanged), for: .valueChanged)

        // UIButton (START||STOP Button UI설정)
        recordButton.setTitle("START", for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.layer.cornerRadius = 5
        recordButton.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        
        // UILabel (LABEL UI 설정)
        textLabel.text = "  1/5 of new frames  \n  Files saved 0/0  "
        textLabel.textColor = .white
        textLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.layer.masksToBounds = true
        textLabel.layer.cornerRadius = 8
        textLabel.sizeToFit()
        textLabel.numberOfLines = 2
        
        //UI화면에 띄움
        let stackView = UIStackView(arrangedSubviews: [
            confidenceControl, recordButton])
        stackView.isHidden = !isUIEnabled
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        view.addSubview(textLabel)
        
        //UI Layout 설정
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            textLabel.heightAnchor.constraint(equalToConstant: 50),
//            textLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    
    //VIEW가 화면에 나타나기 전 설정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a world-tracking configuration, and
        // enable the scene depth frame-semantic.
        //ARSession 설정
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
        
        // Run the view's session 세션 시작
        session.run(configuration)
        // The screen shouldn't dim during AR experiences.
        //화면꺼짐 방지
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    @objc
    func update(){
            renderer.savePointCloud()
    }
    
    //메모리 부족확인
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("memory warning!!!")
        memoryAlert()
        updateIsRecording(_isRecording: false)
    }
    
    //메모리 부족 경고
    private func memoryAlert() {
        let alert = UIAlertController(title: "Low Memory Warning", message: "The recording has been paused. Do not quit the app until all files have been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc //UI 버튼 및 슬라이더 이벤트시 값 변경
    private func viewValueChanged(view: UIView) {
        switch view {
            
        case confidenceControl:
            renderer.confidenceThreshold = confidenceControl.selectedSegmentIndex
         
        case pickFramesSlider:
            renderer.pickFrames = Int(pickFramesSlider.value)
            updateTextLabel()

        default:
            break
        }
    }
    
    @objc //START || STOP 버튼 클릭시
    private func onButtonClick(_ sender: UIButton) {
        if (sender != recordButton) {
            return
        }
        updateIsRecording(_isRecording: !isRecording)
    }
    
    //START-> STOP, STOP->START
    private func updateIsRecording(_isRecording: Bool) {
        isRecording = _isRecording
        if (isRecording){
            recordButton.setTitle("PAUSE", for: .normal)
            recordButton.backgroundColor = .systemRed
            renderer.currentFolder = getTimeStr() //현재 시간저장
            createDirectory(folder: renderer.currentFolder + "/data") //디렉토리 생성
        } else {
            recordButton.setTitle("START", for: .normal)
            recordButton.backgroundColor = .systemBlue
            
            renderer.save_Txt()
        }
        renderer.isRecording = isRecording
    }
    
    // Auto-hide the home indicator to maximize immersion in AR experiences.
    //home indicator 숨김
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences.
    //상태 바 숨김(배터리, 시간, 네트워크신호 등등)
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //ARSession 설정
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        //ARError 발생하면 에러를 띄우고 장면 재구성.
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
        
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.draw()
    }
}

extension MetalViewController: TaskDelegate{
    func didStartTask() {
        self.taskNum += 1
        updateTextLabel()
    }
    
    func didFinishTask() {
        self.completedTaskNum += 1
        updateTextLabel()
    }
    
    private func updateTextLabel() {
        let text = "  1/\(self.renderer.pickFrames)  of new frames  \n  Files saved \(self.completedTaskNum)/\(self.taskNum)  "
        DispatchQueue.main.async {
            self.textLabel.text = text
        }
    }
}


// MARK: - RenderDestinationProvider




