//
//  Ingredient.swift
//  Burp
//
//  Created by William on 5/30/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import Foundation

struct ingData {
	var name : String
	var picName : String
}

extension ingData {
	init?(json: [String : Any]) {
		self.name = json["name"] as! String
		self.picName = json["image"] as! String
	}
}
