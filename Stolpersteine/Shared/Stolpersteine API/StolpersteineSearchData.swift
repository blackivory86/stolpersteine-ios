//
//  StolpersteineSearchData.swift
//  Stolpersteine
//
//  Created by Jan Rose on 06.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import Foundation

#warning("convert this to struct after swift conversion is completed")

@objc
class StolpersteineSearchData: NSObject {
    @objc let keywords: String?
    @objc let street: String?
    @objc let city: String?
    
    @objc public init(keywords: String?, street: String?, city: String?) {
        self.keywords = keywords
        self.street = street
        self.city = city
    }
}
