//
//  LoginViewController.swift
//  Burp
//
//  Created by William on 5/24/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	// MARK: - UIElements
	@IBOutlet weak var AccountTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!
	
	// MARK: - PressButtonActions
	
	@IBAction func LoginPressed(_ sender: UIButton) {
	}
	
	@IBAction func SignUpPressed(_ sender: UIButton) {
	}
	
	
	// MARK: - SceneControl
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
