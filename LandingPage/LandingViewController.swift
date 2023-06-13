//  LandingViewController.swift

import UIKit

class LandingViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var SpaceInformationButton: UIButton!
    
    @IBOutlet var SpaceRegisterButton: UIButton!
    var text = "hello"
    @IBOutlet var SpaceRegisterTextfield: UITextField! { didSet { SpaceRegisterTextfield.delegate = self}}
    
    @IBOutlet var sendButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func SpaceInformationButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func SpaceRegisterButtonTapped(_ sender: UIButton) {
        SpaceInformationButton.isHidden = true
        SpaceRegisterTextfield.isHidden = false
        sendButton.isHidden = false
        globalVariable = "hi world!"

        
    }
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        globalVariable = SpaceRegisterTextfield.text!
    }
}
