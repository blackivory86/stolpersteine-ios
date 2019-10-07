//
//  StolpersteineNetworkService.swift
//  Stolpersteine
//
//  Created by Jan Rose on 06.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import Foundation

@objc
class StolpersteineNetworkService: NSObject {
    
    private enum Constants {
        static let ApiURL = URL(string: "http://api.stolpersteineapp.org/v1")!
    }
    
//    var allowsInvalidSSLCertificate: Bool {
//        set {
//            httpClient.allowsInvalidSSLCertificate = newValue
//        }
//        get {
//            httpClient.allowsInvalidSSLCertificate
//        }
//    }
    
    @objc public var globalErrorHandler: ((Error?) -> ())?
    
    let defaultSearchData: StolpersteineSearchData
    private let httpClient: AFHTTPClient
    private let encodedClientCredentials: String?
    
    init(withClientUser clientUser: String?, password: String?, defaultSearchData: StolpersteineSearchData, allowsInvalidSSLCertificate invalidSSL: Bool = false) {
        
        self.defaultSearchData = defaultSearchData
        
        self.httpClient = AFHTTPClient(baseURL: Constants.ApiURL)
        httpClient.parameterEncoding = AFJSONParameterEncoding
        httpClient.registerHTTPOperationClass(AFJSONRequestOperation.self)
        
        // enable automatic status bar network indicator management
        AFNetworkActivityIndicatorManager.shared()?.isEnabled = true
        
        if let clientUser = clientUser, let password = password {
            let credentials = "\(clientUser):\(password)"
            encodedClientCredentials = credentials.data(using: .utf8)?.base64EncodedString()
        } else {
            encodedClientCredentials = nil
        }
        
        #warning("Re-implement allowsInvalidSSLCert")
//        self.allowsInvalidSSLCertificate = allowsInvalidSSLCertificate
    }
    
    @objc public func retrieveStolpersteine(search: StolpersteineSearchData?, inRange range: NSRange, completionHandler: (([Stolperstein]?, Error?) -> Bool)?) -> URLSessionDataTask? {
        
        let searchParams = createQueryParams(forSearch: search, andRange: range)
        
        let requestURL = Constants.ApiURL.appendingPathComponent("stolpersteine")
        var urlComponents = URLComponents(string: requestURL.absoluteString)
        urlComponents?.queryItems = searchParams.map { URLQueryItem(name: $0.0, value: $0.1 as? String) }
        guard let url = urlComponents?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addCredentials(encodedClientCredentials)
        
        #warning("Re-implement statusbar loading spinner")
        
        let downloadTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    let runGlobalErrorHandler = completionHandler?(nil, error) ?? true
                    
                    if runGlobalErrorHandler {
                        self.handleGlobalError(error)
                    }
                    return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let responseDict = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]]
                let parsedStolpersteine = responseDict?.compactMap { steinJSON in
                    return Stolperstein(fromDict: steinJSON)
                }
                
                DispatchQueue.main.async {
                    _ = completionHandler?(parsedStolpersteine, nil)
                }
            }
        }
        
        
//        operation.allowsInvalidSSLCertifiate = httpClient.allowsInvalidSSLCertificate
        
        downloadTask.resume()
        
        return downloadTask
    }
    
    private func handleGlobalError(_ error: Error?) {
        globalErrorHandler?(error)
    }
    
    private func createQueryParams(forSearch search: StolpersteineSearchData?, andRange range: NSRange) -> [String: Any] {
        let params: [String: Any?] = ["limit": range.length,
                      "offset": range.location,
                      "q": search?.keywords ?? defaultSearchData.keywords,
                      "street": search?.street ?? defaultSearchData.street,
                      "city": search?.city ?? defaultSearchData.city]
        
        // remove parameters with nil values
        return params.compactMapValues { $0 }
    }
}

extension URLRequest {
    mutating func addCredentials(_ credentials: String?) {
        guard let credentials = credentials, !credentials.isEmpty else { return }
        
        self.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
    }
}
