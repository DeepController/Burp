//
//  addCommentViewController.swift
//  Burp
//
//  Created by William on 6/5/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class addCommentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	// MARK: - UIElements
	
	@IBOutlet weak var ratingField: UITextField!
	@IBOutlet weak var commentField: UITextView!
	@IBOutlet weak var imageField: UIImageView!
	@IBOutlet weak var submitButton: UIButton!
	
	// MARK: - Fields
	
	let imagePicker = UIImagePickerController()
	var pickOption = ["★", "★★", "★★★", "★★★★", "★★★★★"]
	var username : String = UserDefaults.standard.string(forKey: defaultsKeys.username)!
	var imageChanged = false
	var selectedImage : UIImage? = nil
	var id = ""
	var pic : UIImage? = nil
	
	// MARK: - View Control
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// PickerView initialization
		let pickerView = UIPickerView()
		pickerView.showsSelectionIndicator = true
		pickerView.delegate = self
		pickerView.dataSource = self
		
		let toolBar = UIToolbar()
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = true
		toolBar.tintColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
		toolBar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addCommentViewController.donePicker))
		let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addCommentViewController.donePicker))
		
		toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		
		ratingField.inputView = pickerView
		ratingField.inputAccessoryView = toolBar
		
		// ImageView Initialization
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(addCommentViewController.ImageViewTapped))
		singleTap.numberOfTapsRequired = 1 // you can change this value
		imageField.isUserInteractionEnabled = true
		imageField.addGestureRecognizer(singleTap)
		
		// ImagePicker Initialization
		imagePicker.delegate = self
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .photoLibrary
		
		// TextView Config
		commentField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
		commentField.layer.borderWidth = 1.0
		commentField.layer.cornerRadius = 5
		
		// submit button config
		submitButton.setTitle("Submitting", for: .disabled)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Actions
	
	@IBAction func submitPressed(_ sender: UIButton) {
		if ratingField.text == nil || ratingField.text == "" || commentField.text == "" {
			let alert = UIAlertController.init(title: "Error!", message: "Please enter rating and comment!", preferredStyle: .alert)
			let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
			alert.addAction(action)
			self.present(alert, animated: true, completion: nil)
		} else {
			submitButton.isEnabled = false
			submitComment()
		}
	}
	
	// Upload Data
	func submitComment() {
		var postString = "id=\(id)&account=\(username)&rating=\(ratingField.text!)&comment=\(commentField.text!)"
		if imageChanged && selectedImage != nil {
			let imageData = UIImageJPEGRepresentation(selectedImage!, 0.5)!
			var b64 = imageData.base64EncodedString()
			b64 = b64.replacingOccurrences(of: "+", with: "%2B")
			postString += "&data=" + b64
		}
		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/addComment.php")!)
		request.httpMethod = "POST"
//		print("The poststring : \(postString)")
		request.httpBody = postString.data(using: .utf8)
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				// check for fundamental networking error
				print("error=\(String(describing: error))")
				return
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
				// check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
			}
			OperationQueue.main.addOperation {
				self.navigationController?.dismiss(animated: true, completion: nil)
			}
			let responseString = String(data: data, encoding: .utf8)!
			print("Feedback: " + responseString)
			print("Upload Complete")
		}
		task.resume()
	}
	
	
	// MARK: - UIPickerView Config
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickOption.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickOption[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		ratingField.text = pickOption[row]
	}
	
	func donePicker() {
		ratingField.resignFirstResponder()
	}
	
	// MARK: - Image Picked Config
	
	func ImageViewTapped() {
		present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imageChanged = true
			selectedImage = pickedImage
			imageField.image = pickedImage
		} else {
			print("Something went wrong")
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
}
