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
