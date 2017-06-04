//
//  RecipeCell.swift
//  Burp
//
//  Created by William on 6/3/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {

	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var pic: UIImageView!
	
	var picName : String = ""
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
