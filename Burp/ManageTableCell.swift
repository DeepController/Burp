//
//  ManageTableViewCell.swift
//  Burp
//
//  Created by William on 6/2/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class ManageTableCell: UITableViewCell {
	
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
}


