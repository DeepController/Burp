//
//  RecipeData.swift
//  Burp
//
//  Created by William on 6/3/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import Foundation


struct recData {
	var id : Int
	var name : String
	var picURL : String
	var miss : Bool
}

extension recData {
	init?(json: [String : Any]) {
		self.name = json["title"] as! String
		self.id = json["id"] as! Int
		self.picURL = json["image"] as! String
		self.miss = (json["missedIngredientCount"] as! Int) != 0
	}
}
