//
//  ConfigurationService.swift
//  Stolpersteine
//
//  Created by Jan Rose on 07.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import Foundation

enum ConfigurationServiceKey: String {
    case APIUser = "API client user"
    case APIPassword = "API client password"
    case GoogleAnalyticsID = "Google Analytics ID"
    case VisibleRegion = "Visible region"
    case FilterCity = "Filter city"
}

class ConfigurationService: NSObject {
    
    private let configuration: [String: Any]
    
    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    static var appShortVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    init?(withConfigurationFile configFile: String) {
        guard let config = NSDictionary(contentsOfFile: configFile) as? [String: Any] else { return nil }
        
        configuration = config
    }
    
    func string(forKey key: ConfigurationServiceKey) -> String? {
        guard let value = configuration[key.rawValue] as? String,
            !value.isEmpty else { return nil }
        return value
    }
    
    func coordinateRegion(forKey key: ConfigurationServiceKey) -> MKCoordinateRegion? {
        guard let regionDict = configuration[key.rawValue] as? [String: Any]
            else { return nil }
        
        guard let lat = regionDict["center.latitude"] as? Double,
            let long = regionDict["center.longitude"] as? Double,
            let latDelta = regionDict["span.latitudeDelta"] as? Double,
            let longDelta = regionDict["span.longitudeDelta"] as? Double
            else { return nil }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long),
                                  span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
    }
}
