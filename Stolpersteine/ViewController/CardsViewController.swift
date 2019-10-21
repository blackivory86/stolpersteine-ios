//
//  CardsViewControllerTableViewController.swift
//  Stolpersteine Berlin
//
//  Created by Jan Rose on 14.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit

class CardsViewController: UITableViewController {
    
    private struct Constants {
        static let cellIdentifier = "CardsCell"
        
        struct Segues {
            static let ToCards = "stolpersteinCardsViewControllerToStolpersteinCardsViewController"
            static let ToDescription = "stolpersteinCardsViewControllerToStolpersteinDescriptionViewController"
        }
    }
    
    public var stolpersteine: [Stolperstein]?
    var searchData: StolpersteineSearchData?
    private var searchOperation: URLSessionDataTask?
    
    private var linksDisasbled: Bool {
        return searchData != nil
    }
    
    private lazy var measuringCell: StolpersteinCardCell? = {
        tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as? StolpersteinCardCell
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = getRowHeightMeasure()
        
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil) { [weak self] (_) in
            guard let self = self else { return }
            self.tableView.estimatedRowHeight = self.getRowHeightMeasure()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard stolpersteine == nil, let searchData = searchData else { return }
        
        searchOperation?.cancel()
        
        searchOperation = AppDelegate.networkService?.retrieveStolpersteine(search: searchData, inRange: NSMakeRange(0, 0), completionHandler: { [weak self] (stolpersteine, error) -> Bool in
            guard let self = self else { return false }
            
            self.stolpersteine = stolpersteine
            self.title = searchData.street
            self.tableView.reloadData()
            
            return false
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.diagnosticsService?.trackView(withClass: type(of: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Make sure that selection menu controller on table cell gets hidden
        UIMenuController.shared.setMenuVisible(false, animated: true)
        
        searchOperation?.cancel()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willRotate(to: toInterfaceOrientation, duration: duration)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath: IndexPath? = {
            if sender as? CCHLinkTextView != nil,
                let senderView = sender as? UIView {
                let pointInTableView = tableView.convert(senderView.center, from: senderView)
                return tableView.indexPathForRow(at: pointInTableView)
            } else {
                return tableView.indexPathForSelectedRow
            }
        }()
        
        guard let selectedIndexPath = indexPath,
            let cardCell = tableView.cellForRow(at: selectedIndexPath) as? StolpersteinCardCell else {
            print("could not get a stolperstein from sender")
            return
        }
        let stolperstein = cardCell.stolperstein
        
        
        if segue.identifier == Constants.Segues.ToCards,
            let navigationController = segue.destination as? UINavigationController,
            let cardsViewController = navigationController.topViewController as? CardsViewController {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: cardsViewController, action: #selector(dismissViewController))
            cardsViewController.navigationItem.rightBarButtonItem = barButtonItem
            
            let searchData = StolpersteineSearchData(keywords: nil, street: stolperstein.streetName, city: nil)
            cardsViewController.searchData = searchData
        } else if segue.identifier == Constants.Segues.ToDescription,
            let descriptionVC = segue.destination as? DescriptionViewController {
            descriptionVC.stolperstein = stolperstein
            descriptionVC.title = stolperstein.name
        }
    }
    
    @objc
    private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    private func getRowHeightMeasure() -> CGFloat {
        guard let measuringCell = measuringCell else { return .leastNonzeroMagnitude}
        
        measuringCell.update(withStolperstein: StolpersteinCardCell.standardStolperstein, linksDisabled: linksDisasbled, index: 0)
        
        return measuringCell.heightForCurrentStolperstein(withTableViewWidth: tableView.frame.size.width)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stolpersteine?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getRowHeightMeasure()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        guard let cardCell = cell as? StolpersteinCardCell, let stolperstein = stolpersteine?[indexPath.row] else {
            return cell
        }
        
        cardCell.linkDelegate = self
        cardCell.update(withStolperstein: stolperstein, linksDisabled: linksDisasbled, index: indexPath.row)
        
        if cardCell.canSelectCurrentStolperstein {
            cardCell.selectionStyle = .gray
        } else {
            cardCell.selectionStyle = .none
        }
        
        return cardCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cardCell = tableView.cellForRow(at: indexPath) as? StolpersteinCardCell else {
            return
        }
        
        if cardCell.canSelectCurrentStolperstein {
            performSegue(withIdentifier: Constants.Segues.ToDescription, sender: self)
        }
    }
}

extension CardsViewController: CCHLinkTextViewDelegate {
    func linkTextView(_ linkTextView: CCHLinkTextView!, didTapLinkWithValue value: Any!) {
        performSegue(withIdentifier: Constants.Segues.ToCards, sender: linkTextView)
    }
    
    func linkTextView(_ linkTextView: CCHLinkTextView!, didLongPressLinkWithValue value: Any!) {
        performSegue(withIdentifier: Constants.Segues.ToCards, sender: linkTextView)
    }
}
