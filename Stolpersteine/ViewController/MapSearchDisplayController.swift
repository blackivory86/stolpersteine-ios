//
//  MapSearchDisplayController.swift
//  Stolpersteine
//
//  Created by Jan Rose on 21.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit

class MapSearchDisplayController: UISearchController {
    private struct Constants {
        static let requestDelay: TimeInterval = 0.3
        static let requestSize = 100
    }
    
    private var originalBarButtonItem: UIBarButtonItem?
    private var delayedSearchUpdate: DispatchWorkItem?
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        
        hidesNavigationBarDuringPresentation = false
//
//        automaticallyShowsCancelButton = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapSearchDisplayController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateSearch(withString: searchController.searchBar.text)
    }
    
    private func updateSearch(withString searchString: String?) {
        delayedSearchUpdate?.cancel()
        
        let delayedSearch = DispatchWorkItem(block: { [weak self] in
            // make sure UI is updated on main thread
            DispatchQueue.main.async { [weak self] in
                self?.updateSearchData(searchString ?? "")
            }
        })
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + Constants.requestDelay, execute: delayedSearch)
        
        delayedSearchUpdate = delayedSearch
    }
    
    private func updateSearchData(_ searchString: String){
        let searchData = StolpersteineSearchData(keywords: searchString, street: nil, city: nil)
        (searchResultsController as? MapSearchResultsViewController)?.searchData = searchData
    }
}

extension MapSearchDisplayController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        originalBarButtonItem = navigationItem.rightBarButtonItem
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        AppDelegate.diagnosticsService?.trackEvent(.searchStarted, withClass: type(of: self))
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationItem.setRightBarButton(originalBarButtonItem, animated: true)
    }
}


class MapSearchResultsViewController: UITableViewController {
    private struct Constants {
        static let requestSize = 100
        static let searchCell = "cell"
    }
    
    internal var zoomDistance: Double?

    internal var networkService: StolpersteineNetworkService?
    internal var mapClusterController: CCHMapClusterController?
    internal var searchData: StolpersteineSearchData? {
        didSet {
            updateSearch()
        }
    }
    private var searchedStolpersteine: [Stolperstein]?
    private var searchTask: URLSessionDataTask?
    internal weak var searchController: UISearchController?
    
    private func updateSearch() {
        searchTask?.cancel()
        
        searchTask = networkService?.retrieveStolpersteine(search: searchData, inRange: NSRange(location: 0, length: Constants.requestSize), completionHandler: { (stolpersteine, error) -> Bool in
            // make sure UI is updated on main thread
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.searchedStolpersteine = stolpersteine
                strongSelf.tableView.reloadData()
                strongSelf.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
            }
            
            return false
        })
    }
}

// MARK: UITableViewDataSource

extension MapSearchResultsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedStolpersteine?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.searchCell) ?? UITableViewCell(style: .subtitle, reuseIdentifier: Constants.searchCell)
        cell.selectionStyle = .gray
        
        let stolperstein = searchedStolpersteine?[indexPath.row]
        cell.textLabel?.text = stolperstein?.name
        cell.detailTextLabel?.text = stolperstein?.shortAddress
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension MapSearchResultsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Dismiss search display
        searchController?.isActive = false
        
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
