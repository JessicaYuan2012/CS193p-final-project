//
//  NewTransactionViewController.swift
//  AccountBook
//
//  Created by yang on 3/6/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit


// Cite: https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/
class NewTransactionViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBAction func addImage(_ sender: UIButton) {
        present(alert, animated: true, completion: nil)
    }
    
    var image: UIImage?
    
    // MARK: - Image Picker
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    private func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        }
        else {
            noCamera()
        }
    }
    
    private func noCamera() { // for simulator
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func choosePhotoFromLibrary() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        let ppc = picker.popoverPresentationController
        ppc?.sourceView = view
        // Cite: http://stackoverflow.com/questions/31759615/how-to-center-a-popoverview-in-swift
        ppc?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0) // show it at center
        ppc?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - public API of transaction type
    var transactionType: String? {
        didSet{
            if transactionType != nil {
                self.navigationItem.title = "Add " + transactionType!
            }
        }
    }
    
    // MARK: - (Category) PickerView Data Source and Delegate
    private let expenseCategories = ["Necessaries", "Shopping", "Transportation", "Fee", "Others"]
    
    private let incomeCategories = ["Salary", "Finance", "Others"]
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if transactionType == nil {
            return 0
        } else if transactionType! == "Expense" {
            return expenseCategories.count
        } else {
            return incomeCategories.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if transactionType == nil {
            return nil
        } else if transactionType! == "Expense" {
            return expenseCategories[row]
        } else {
            return incomeCategories[row]
        }
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.restorationIdentifier != nil, textField.restorationIdentifier! == "AmountTextField" {
            if textField.text != nil, textField.text! != "" {
                let numberFormatter = NumberFormatter()
                if let enteredAmount = numberFormatter.number(from: textField.text!) {
                    if enteredAmount.compare(NSNumber(value: 0.0)) == .orderedDescending {
                        doneButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    // MARK: - Manually add done button for decimal pad
    // Cite: http://stackoverflow.com/questions/28338981/how-to-add-done-button-to-numpad-in-ios-8-using-swift
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.amountTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.amountTextField.resignFirstResponder()
    }
    
    // MARK: - ImagePickerDelegate
    let picker = UIImagePickerController()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        self.image = chosenImage
        addImageButton.setTitle("Change Image", for: .normal)
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.date = Date().currentDate() // clear the time
    }
    
    override func viewDidLoad() {
        amountTextField.delegate = self
        commentTextField.delegate = self
        picker.delegate = self
        datePicker.maximumDate = Date()
        addDoneButtonOnKeyboard()
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) {
            [weak self] (action: UIAlertAction) -> Void in
            self?.shootPhoto()
        })
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default) {
            [weak self] (action: UIAlertAction) -> Void in
            self?.choosePhotoFromLibrary()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) -> Void in })
        alert.modalPresentationStyle = .popover
        let ppc = alert.popoverPresentationController
        ppc?.sourceView = view
        // Cite: http://stackoverflow.com/questions/31759615/how-to-center-a-popoverview-in-swift
        ppc?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0) // show it at center
        ppc?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
