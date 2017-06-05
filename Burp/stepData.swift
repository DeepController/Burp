//
//  stepData.swift
//  Burp
//
//  Created by William on 6/4/17.
//  Copyright © 2017 Yang Wang. All rights reserved.
//

import Foundation

struct stepData {
	var content : String
}

extension stepData {
	init?(json: [String : Any]) {
		self.content = json["step"] as! String
	}
}
