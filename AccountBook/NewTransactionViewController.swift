//
//  NewTransactionViewController.swift
//  AccountBook
//
//  Created by yang on 3/6/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

// CITE: https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/
class NewTransactionViewController: UITableViewController, UINavigationControllerDelegate {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBAction func addImage(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
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
        alert.view.tintColor = UIColor.themeColor()
        let ppc = alert.popoverPresentationController
        ppc?.sourceView = view
        ppc?.sourceRect = view.bounds
        ppc?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        present(alert, animated: true, completion: nil)
    }
    
    var image: UIImage?
    
    var transactionType: String? {
        didSet{
            if transactionType != nil {
                self.navigationItem.title = "Add " + transactionType!
            }
        }
    }
    
    fileprivate let expenseCategories = ["Necessaries", "Shopping", "Transportation", "Fee", "Others"]
    
    fileprivate let incomeCategories = ["Salary", "Finance", "Others"]
    
    // MARK: - Manually add done button for decimal pad
    // CITE: http://stackoverflow.com/questions/28338981/how-to-add-done-button-to-numpad-in-ios-8-using-swift
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
    
    // MARK: - Image Picker
    private let imagePicker = UIImagePickerController()
    
    private func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
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
        alertVC.view.tintColor = UIColor.themeColor()
        present(alertVC, animated: true, completion: nil)
    }
    
    private func choosePhotoFromLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.modalPresentationStyle = .popover
        let ppc = imagePicker.popoverPresentationController
        ppc?.sourceView = view
        ppc?.sourceRect = view.bounds
        ppc?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Party LET", size: 30.0)!, NSForegroundColorAttributeName: UIColor.white]
        self.doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Party LET", size: 30.0)!, NSForegroundColorAttributeName: UIColor.lightGray], for: .disabled)
        self.doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Party LET", size: 30.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
    }
    
    override func viewDidLoad() {
        datePicker.date = Date().currentDate() // clear the time
        amountTextField.delegate = self
        commentTextField.delegate = self
        imagePicker.delegate = self
        datePicker.maximumDate = Date()
        addDoneButtonOnKeyboard()
    }
}

extension NewTransactionViewController: UITextFieldDelegate {
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
                        return
                    }
                }
            }
            doneButton.isEnabled = false
        }
    }
}

extension NewTransactionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
}

extension NewTransactionViewController: UIImagePickerControllerDelegate {
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
}
