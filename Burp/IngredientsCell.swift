//
//  IngredientsCell.swift
//  Burp
//
//  Created by William on 5/29/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class IngredientsCell: UITableViewCell {
	
	// MARK: - UIElements
	
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var pic: UIImageView!
	@IBOutlet weak var addButton: UIButton!
	
	// MARK: - Fields
	var username : String = ""
	var picname : String = ""
	
	// MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	@IBAction func addPressed(_ sender: UIButton) {
		if self.addButton.titleLabel!.text! == "Add" {
			self.addButton.setTitle("Adding", for: .normal)
			modifyIngredientOnServer(action: "add")
		} else {
			self.addButton.setTitle("Removing", for: .normal)
			modifyIngredientOnServer(action: "delete")
		}
	}

	fileprivate func modifyIngredientOnServer(action : String) {
		var request = URLRequest(url: URL(string: "https://students.washington.edu/yangw97/Burp/ingredient.php")!)
		request.httpMethod = "POST"
		let postString = "action=\(action)&account=\(username)&ingredient_name=\(name.text!)&ingredient_image=\(picname)"
		request.httpBody = postString.data(using: .utf8)
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let _ = data, error == nil else {
				// check for fundamental networking error
				print("error=\(String(describing: error))")
				return
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
				// check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
			}
			if action == "add" {
				OperationQueue.main.addOperation {
					self.addButton.setTitle("Remove", for: .normal)
					self.addButton.setTitleColor(UIColor.red, for: .normal)
				}
			} else {
				OperationQueue.main.addOperation {
					self.addButton.setTitle("Add", for: .normal)
					self.addButton.setTitleColor(UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1), for: .normal)
				}
			}
		}
		task.resume()
	}

}
