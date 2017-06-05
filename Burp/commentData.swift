//
//  commentData.swift
//  Burp
//
//  Created by William on 6/5/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import Foundation

struct commentData {
	var picName : String
	var name : String
	var rating : String
	var content : String
}

extension commentData {
	init?(json: [String : Any]) {
		self.name = json["account"] as! String
//		self.picName = json["id"] as! String
		self.rating = json["rating"] as! String
		self.content = json["comment"] as! String
		if let img = json["image"] {
			self.picName = img as! String
		} else {
			self.picName = ""
		}
	}
}
