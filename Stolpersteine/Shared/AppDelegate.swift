//
//  AppDelegate.swift
//  Stolpersteine Berlin
//
//  Created by Jan Rose on 06.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    @objc static var configurationService: ConfigurationService? = {
        let configFile = Bundle.main.path(forResource: "Stolpersteine-Config", ofType: "plist")
        return ConfigurationService(configurationsFile: configFile)
    }()
    
    @objc static var networkService: StolpersteineNetworkService? = {
        guard let configurationService = AppDelegate.configurationService else { return nil }
        
        let defaultSearch = StolpersteineSearchData(keywords: nil,
        street: nil,
        city: configurationService.stringConfiguration(for: ConfigurationServiceKeyFilterCity))
        let networkService = StolpersteineNetworkService(withClientUser: configurationService.stringConfiguration(for: ConfigurationServiceKeyAPIUser),
                                                         password: configurationService.stringConfiguration(for: ConfigurationServiceKeyAPIPassword),
                                                         defaultSearchData: defaultSearch)
        return networkService
    }()
    
    @objc static var diagnosticsService: DiagnosticsService? = {
        return DiagnosticsService(googleAnalyticsID: AppDelegate.configurationService?.stringConfiguration(for: ConfigurationServiceKeyGoogleAnalyticsID))
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        guard !AppDelegate.isUnitTesting else { return true }
        
        print("Stolpersteine \(ConfigurationService.appShortVersion() ?? "") (\(ConfigurationService.appVersion() ?? ""))")
        
        let networkService = AppDelegate.networkService
        networkService?.globalErrorHandler = { error in
            let alert = UIAlertView(title: NSLocalizedString("AppDelegate.errorTitle", comment: ""),
                                    message: NSLocalizedString("AppDelegate.errorMessage", comment: ""),
                                    delegate: nil,
                                    cancelButtonTitle: NSLocalizedString("AppDelegate.errorButtonTitle", comment: ""))
            alert.show()
        }
        
        #if DEBUG
        networkService?.allowsInvalidSSLCertificate = true
        #endif
        
        return true
    }
    
}

extension AppDelegate {
    static var isUnitTesting: Bool {
        return ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil
    }
}
