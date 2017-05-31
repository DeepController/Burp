//
//  ViewController.swift
//  Burp
//
//  Created by William on 5/18/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func popAlert(content : String) {
		let alert = UIAlertController.init(title: "Error!", message: content, preferredStyle: .alert)
		let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
		alert.addAction(action)
		self.present(alert, animated: true, completion: nil)
	}
	
}

