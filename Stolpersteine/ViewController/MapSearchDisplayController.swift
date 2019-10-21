//
//  MapSearchDisplayController.swift
//  Stolpersteine
//
//  Created by Jan Rose on 21.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit

class MapSearchDisplayController: UISearchDisplayController {
    private struct Constants {
        static let requestDelay = 0.3
        static let requestSize = 100
        static let searchCell = "cell"
    }
    
    internal var networkService: StolpersteineNetworkService?
    internal var mapClusterController: CCHMapClusterController?
    internal var zoomDistance: Double?
    
    private var searchedStolpersteine: [Stolperstein]?
    private var searchTask: URLSessionDataTask?
    private var originalBarButtonItem: UIBarButtonItem?
}

extension MapSearchDisplayController: UISearchDisplayDelegate {
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(updateSearchData(_:)), with: searchString, afterDelay: Constants.requestDelay)
        
        return false
    }
    
    func searchDisplayControllerWillBeginSearch(_ controller: UISearchDisplayController) {
        originalBarButtonItem = navigationItem?.rightBarButtonItem
        controller.navigationItem?.setRightBarButton(nil, animated: true)
        controller.searchBar.setShowsCancelButton(true, animated: false)
    }
    
    func searchDisplayControllerWillEndSearch(_ controller: UISearchDisplayController) {
        searchTask?.cancel()
        controller.navigationItem?.setRightBarButton(originalBarButtonItem, animated: true)
        controller.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchDisplayControllerDidBeginSearch(_ controller: UISearchDisplayController) {
        AppDelegate.diagnosticsService?.trackEvent(.searchStarted, withClass: type(of: self))
    }
    
    @objc private func updateSearchData(_ searchString: String){
        searchTask?.cancel()
        
        let searchData = StolpersteineSearchData(keywords: searchString, street: nil, city: nil)
        searchTask = networkService?.retrieveStolpersteine(search: searchData, inRange: NSRange(location: 0, length: Constants.requestSize), completionHandler: { (stolpersteine, error) -> Bool in
            self.searchedStolpersteine = stolpersteine
            self.searchResultsTableView.reloadData()
            self.searchResultsTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
            
            return false
        })
    }
}

extension MapSearchDisplayController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedStolpersteine?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.searchCell) ?? UITableViewCell(style: .subtitle, reuseIdentifier: Constants.searchCell)
        cell.selectionStyle = .gray
        
        let stolperstein = searchedStolpersteine?[indexPath.row]
        cell.textLabel?.text = stolperstein?.name
        cell.detailTextLabel?.text = stolperstein?.shortAddress
        
        return cell
    }
}

extension MapSearchDisplayController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Dismiss search display controller
        isActive = false
        
        guard let stolperstein = searchedStolpersteine?[indexPath.row] else {
            return
        }
        
        if let mapClusterController = mapClusterController,
            let zoomDistance = zoomDistance {
            mapClusterController.addAnnotations([stolperstein], withCompletionHandler: { [weak mapClusterController, zoomDistance] in
                mapClusterController?.selectAnnotation(stolperstein, andZoomToRegionWithLatitudinalMeters: zoomDistance, longitudinalMeters: zoomDistance)
            })
        }
    }
}
