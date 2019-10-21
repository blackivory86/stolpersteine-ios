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
        guard let configFile = Bundle.main.path(forResource: "Stolpersteine-Config", ofType: "plist")
            else { return nil }
        return ConfigurationService(withConfigurationFile: configFile)
    }()
    
    @objc static var networkService: StolpersteineNetworkService? = {
        guard let configurationService = AppDelegate.configurationService else { return nil }
        
        let defaultSearch = StolpersteineSearchData(keywords: nil,
        street: nil,
        city: configurationService.string(forKey: .FilterCity))
        let networkService = StolpersteineNetworkService(withClientUser: configurationService.string(forKey: .APIUser),
                                                         password: configurationService.string(forKey: .APIPassword),
                                                         defaultSearchData: defaultSearch)
        return networkService
    }()
    
    @objc static var diagnosticsService: DiagnosticsService? = {
        guard let googleAnalyticsID = AppDelegate.configurationService?.string(forKey: .GoogleAnalyticsID) else {
            print("missing Google Analytics config (ID)")
            return nil
        }
        return DiagnosticsService(withGoogleAnalyticsID: googleAnalyticsID)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        guard !AppDelegate.isUnitTesting else { return true }
        
        print("Stolpersteine \(ConfigurationService.appShortVersion ?? "") (\(ConfigurationService.appVersion ?? ""))")
        
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
