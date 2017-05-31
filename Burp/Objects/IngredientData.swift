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
		self.quizTitle = json["title"] as! String
		self.quizDesc = json["desc"] as! String
		let arr = json["questions"] as! [Any]
		for question in arr {
			let dict = question as! [String:Any]
			self.questionArr.append(quizItem.init(json: dict)!)
		}
	}
}
