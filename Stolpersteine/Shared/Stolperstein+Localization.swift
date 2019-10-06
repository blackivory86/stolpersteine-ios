//
//  Stolperstein+Localization.swift
//  Stolpersteine Berlin
//
//  Created by Jan Rose on 04.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import Foundation

@objc
extension Stolperstein {
    var name: String {
        #warning("needs localization")
        let type = (stolpersteinType == .schwelle) ? "(Stolpersteinschwelle)" : ""
        let concatenated = "\(personFirstName ?? "") \(personLastName ?? "") \(type)"
        return concatenated.trimmingCharacters(in: .whitespaces)
    }
    
    var shortName: String {
        let initial: String = {
            if let firstChar = personFirstName?.prefix(1) {
                return "\(firstChar)."
            }
            return ""
        }()
        
        let shortName = "\(initial) \(personLastName ?? "")"
        return shortName.trimmingCharacters(in: .whitespaces)
    }
    
    var streetName: String {
        guard var street = locationStreet else { return "" }
        
        let digitRange = locationStreet?.rangeOfCharacter(from: .decimalDigits)
        
        if let digitRange = digitRange {
            street.removeSubrange(digitRange)
        }
        return street.trimmingCharacters(in: .whitespaces)
    }
    
    var shortAddress: String {
        let zipAndCity = "\(locationZIP ?? "") \(locationCity ?? "")".trimmingCharacters(in: .whitespaces)
        
        let components: [String] = [locationStreet, zipAndCity].filter { !($0?.isEmpty ?? false) }
            .compactMap{ $0 }
        
        return components.joined(separator: ", ")
    }
    
    var longAddress: String {
        let longAddress = "\(locationStreet ?? "")\n\(locationZIP ?? "") \(locationCity ?? "")"
        return longAddress.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var localizedBiographyURL: URL? {
        guard let absoluteURL = biographyURL?.absoluteString else { return biographyURL }
        
        let prefixGerman = "http://www.stolpersteine-berlin.de/de"
        let prefixEnglish = "http://www.stolpersteine-berlin.de/en"
        
        if NSLocale.preferredLanguages.first?.hasPrefix("de") ?? false, absoluteURL.hasPrefix(prefixGerman) {
            let localizedURL = absoluteURL.replacingOccurrences(of: prefixGerman, with: prefixEnglish)
            return URL(string: localizedURL)
        }
        
        return biographyURL
    }
    
    var pasteboardString: String {
        return "\(name)\n\(shortAddress)\n\(localizedBiographyURL?.absoluteString ?? "")"
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n\n", with: "\n")
    }
}
