//
//  CCHMapClusterAnnotation+Localization.swift
//  Stolpersteine
//
//  Created by Jan Rose on 05.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit

extension CCHMapClusterAnnotation {
    var stolpersteineTitle: String {
        if isCluster() {
            return annotations
                .compactMap { $0 as? Stolperstein }
                .prefix(5)
                .map { $0.name }
                .joined(separator: ", ")
        } else {
            return (annotations.first as? Stolperstein)?.name ?? ""
        }
    }
    
    var stolpersteineSubtitle: String {
        if isUniqueLocation() {
            return (annotations.first as? Stolperstein)?.shortAddress ?? ""
        } else {
            return stolpersteineCount
        }
    }
    
    var stolpersteineCount: String {
        let key = annotations.count > 1 ? "Misc.stolpersteine" : "Misc.stolperstein"
        let localizedName = NSLocalizedString(key, comment: "")
        return String.localizedStringWithFormat(localizedName, annotations.count)
    }
}
