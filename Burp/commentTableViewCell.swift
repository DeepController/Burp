//
//  commentTableViewCell.swift
//  Burp
//
//  Created by Yichao Wang on 5/31/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import UIKit

class commentTableViewCell: UITableViewCell {

    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!    
    @IBOutlet weak var review: UILabel!
	
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
