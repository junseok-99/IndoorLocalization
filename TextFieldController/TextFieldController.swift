//  TextFieldController.swift

import UIKit

class TextFieldController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var btnStart: UIButton!
    @IBOutlet var spaceTextField: UITextField! { didSet { spaceTextField.delegate = self}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        globalVariable = spaceTextField.text ?? ""
        view.endEditing(true)
        print(globalVariable)
        if(globalVariable.isEmpty){
            btnStart.isEnabled = false
        }
        else{
            btnStart.isEnabled = true
        }
    }
}
