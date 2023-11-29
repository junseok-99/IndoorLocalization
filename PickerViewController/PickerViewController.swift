//  PickerViewController.swift



import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet var btnStart: UIButton!
    @IBOutlet var floorName: UITextField!
    @IBOutlet var spaceName: UITextField!
    
//    let countryData = ["계당관(S)", "식물과학관(N)", "한누리관(I)", "디자인대학(D)", "송백관(E)"]
    let countryData = ["식물과학관(N)", "한누리관(I)"]
//    let countryIdentifier = ["S", "N", "I", "D", "E"]
    let countryIdentifier = ["N", "I"]
    
//    let floorData = [
//        "계당관(S)": ["1F", "2F", "3F"],
//        "식물과학관(N)": ["202"],
//        "한누리관(I)": ["1F", "2F", "3F", "4F", "5F", "6F", "7F", "8F", "9F", "10F"],
//        "디자인대학(D)": ["1F", "2F", "3F", "4F"],
//        "송백관(E)": ["1F", "2F", "3F", "4F", "5F"]
//    ]
    let floorData = [
        "식물과학관(N)": ["202"],
        "한누리관(I)": ["1F", "3F", "7F", "718"],
    ]
    
    var rightColumnData = [String]()
    
    let spacePickerView = UIPickerView()
    let floorPickerView = UIPickerView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spacePickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220)
        spacePickerView.delegate = self
        spacePickerView.dataSource = self
        floorPickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220)
        floorPickerView.delegate = self
        floorPickerView.dataSource = self
        
        let toolBar: UIToolbar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.backgroundColor = .lightGray
        toolBar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
        toolBar.setItems([btnCancel, space, btnDone], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        let toolBar2: UIToolbar = UIToolbar()
        toolBar2.barStyle = .default
        toolBar2.isTranslucent = true
        toolBar2.backgroundColor = .lightGray
        toolBar2.sizeToFit()
        let btnDone2 = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone2))
        let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel2 = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel2))
        toolBar2.setItems([btnCancel2, space2, btnDone2], animated: true)
        toolBar2.isUserInteractionEnabled = true
        
        spaceName.inputView = spacePickerView
        spaceName.inputAccessoryView = toolBar
        
        floorName.inputView = floorPickerView
        floorName.inputAccessoryView = toolBar2
        
    }
    @IBAction func StartInfo(_ sender: UIButton) {
        globalIdentifier += "_" + globalFloor
        
        floorName.text = ""
        spaceName.text = ""
        btnStart.isEnabled = false
    }
    
    @objc
    func onPickDone(){
        if(globalSpace.isEmpty){
            globalSpace = countryData[0]
            globalIdentifier = countryIdentifier[0]
        }
        
        spaceName.text = globalSpace
        spaceName.resignFirstResponder()
        
        globalFloor = ""
        floorName.text = ""
        
        if(globalSpace.isEmpty || globalFloor.isEmpty){
            btnStart.isEnabled = false
        }
        else{
            btnStart.isEnabled = true
        }
    }
    
    
    @objc
    func onPickCancel(){
        spaceName.resignFirstResponder()
    }
    
    @objc
    func onPickDone2(){
        if(!globalSpace.isEmpty && globalFloor.isEmpty){
            globalFloor = floorData[globalSpace]?[0] ?? ""
        }
        floorName.text = globalFloor
        floorName.resignFirstResponder()
        
        if(globalSpace.isEmpty || globalFloor.isEmpty){
            btnStart.isEnabled = false
        }
        else{
            btnStart.isEnabled = true
        }
    }
    
    @objc
    func onPickCancel2(){
        floorName.resignFirstResponder()
    }
    
    
    // UIPickerViewDelegate & UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == spacePickerView {
            return countryData.count
        }
        else if pickerView == floorPickerView {
            if (globalSpace.isEmpty){
                return 0
            }
            else{
                if let tmp = floorData[globalSpace]{
                    return tmp.count
                } else{
                    return 0
                }
            }
        }
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == spacePickerView {
            return countryData[row]
        }
        else if pickerView == floorPickerView {
            if let tmp = floorData[globalSpace]{
                return tmp[row]
            } else{
                return nil
            }
        }
        return nil
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == spacePickerView {
            globalSpace = countryData[row]
            globalIdentifier = countryIdentifier[row]
            print(globalSpace)
        } else {
            if let tmp = floorData[globalSpace]{
                globalFloor = tmp[row]
            } else{
                globalFloor = ""
            }
            print(globalFloor)
        }
     
    }
    
}
