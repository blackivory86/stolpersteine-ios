//
//  StolpersteineSynchronizationController.swift
//  Stolpersteine
//
//  Created by Jan Rose on 07.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import Foundation

@objc
protocol StolpersteineSynchronizationControllerDelegate {
    func controller(_ controller: StolpersteineSynchronizationController, didAddStolpersteine: [Stolperstein])
    func controller(_ controller: StolpersteineSynchronizationController, didRemoveStolpersteine: [Stolperstein])
}

@objc
class StolpersteineSynchronizationController: NSObject {
    
    private enum Constants {
        static let BatchSize = 500
    }
    
    private let networkService: StolpersteineNetworkService
    @objc public var delegate: StolpersteineSynchronizationControllerDelegate?
    
    private var isSynchronizing: Bool = false
    private var retrievalTask: URLSessionDataTask?
    private var stolpersteine: Set<Stolperstein> = []
    
    @objc init(withNetworkService networkService: StolpersteineNetworkService) {
        self.networkService = networkService
    }
    
    @objc public func synchronize() {
        guard !isSynchronizing else { return }
        
        isSynchronizing = true
        
        retrieveStolpersteine()
    }
    
    private func retrieveStolpersteine(withRange range: NSRange = NSMakeRange(0, Constants.BatchSize)) {
        retrievalTask?.cancel()
        
        retrievalTask = networkService.retrieveStolpersteine(search: nil, inRange: range, completionHandler: { (result, error) -> Bool in
            guard error == nil else {
                self.isSynchronizing = false
                return self.stolpersteine.isEmpty
            }
            
            self.didRetrieve(result)
            
            if result?.count == range.length {
                // there might be more to retrieve - query next batch
                let nextRange = NSMakeRange(NSMaxRange(range), range.length)
                self.retrieveStolpersteine(withRange: nextRange)
            } else {
                self.isSynchronizing = false
            }
            
            return self.stolpersteine.isEmpty
        })
    }
    
    private func didRetrieve(_ retrievedStolpersteine: [Stolperstein]?) {
        guard let retrievedStolpersteine = retrievedStolpersteine else { return }
        
        let retrieved = Set<Stolperstein>(retrievedStolpersteine)
        let new = retrieved.subtracting(stolpersteine)
        
        self.stolpersteine = stolpersteine.union(new)
        
        if !new.isEmpty {
            delegate?.controller(self, didAddStolpersteine: Array(new))
        }
        
    }
}
