//
//  LoginViewController.swift
//  Burp
//
//  Created by William on 5/24/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class LoginViewController: ViewController, UITextFieldDelegate {

	// MARK: - UIElements
	@IBOutlet weak var AccountTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!
	
	let loading = ProgressHUD(text: "Logging in")
	
	// MARK: - PressButtonActions
	
	@IBAction func LoginPressed(_ sender: UIButton) {
		self.view.addSubview(loading)
		askServer(to: "validate", account: AccountTextField.text!, password: PasswordTextField.text!)
	}
	
	@IBAction func SignUpPressed(_ sender: UIButton) {
		self.view.addSubview(loading)
		if checkAccountPasswordLegality() {
			askServer(to: "create", account: AccountTextField.text!, password: PasswordTextField.text!)
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField === AccountTextField {
			PasswordTextField.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
		}
		return true
	}
	
//	fileprivate func popAlert(content : String) {
//		let alert = UIAlertController.init(title: "Error!", message: content, preferredStyle: .alert)
//		let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
//		alert.addAction(action)
//		self.present(alert, animated: true, completion: nil)
//	}
	
	fileprivate func checkAccountPasswordLegality() -> Bool {
		let account = AccountTextField.text!
		let password = PasswordTextField.text!
		if !checkStringValidity(of: account) || !checkStringValidity(of: password) {
			loading.removeFromSuperview()
			super.popAlert(content: "The account/password must contains more than 6 alphanumeric characters only.")
			return false
		}
		return true
	}
	
	fileprivate func checkStringValidity(of word : String) -> Bool{
		return word.range(of: "^[a-zA-Z0-9]{6,}$", options: .regularExpression, range: nil, locale: nil) != nil
	}
	
	// MARK: - Remote Validation

	fileprivate func askServer(to action : String, account : String, password : String) {
		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/validate.php")!)
		request.httpMethod = "POST"
		let postString = "action=\(action)&account=\(account)&password=\(password)"
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
			
			let responseString = String(data: data, encoding: .utf8)
			self.handleResponse(content: responseString!)
		}
		task.resume()
	}
	
	fileprivate func handleResponse(content : String) {
		OperationQueue.main.addOperation{
			self.loading.removeFromSuperview()
		}
		switch content {
		case _ where content.contains("existed"):
			OperationQueue.main.addOperation{
				super.popAlert(content: "The account is already exist. Please try another one.")
			}
		case _ where content.contains("false"):
			OperationQueue.main.addOperation{
				super.popAlert(content: "Please check your account and password.")
			}
		default:
			OperationQueue.main.addOperation{
				self.performSegue(withIdentifier: "LoginToAddSegue", sender: nil)
			}
		}
	}

	
	// MARK: - SceneControl
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "LoginToAddSegue" {
			let navController = segue.destination as! UINavigationController
			let destinationController = navController.topViewController as! AddIngredientsTableViewController
			destinationController.username = AccountTextField.text!
			//			dest.quizIndex = self.tableView.indexPath(for: sender as! UITableViewCell)!.row
			//			allQuestion.populate(id: self.tableView.indexPath(for: sender as! UITableViewCell)!.row)
			//			dest.questionVault = allQuestion
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		AccountTextField.delegate = self
		PasswordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
