//
//  DescriptionViewController.swift
//  Stolpersteine Berlin
//
//  Created by Jan Rose on 18.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit
import Contacts

class DescriptionViewController: UIViewController {
    
    public var stolperstein: Stolperstein?
    
    @IBOutlet weak var webView: UIWebView?
    @IBOutlet var activityBarButtonItem: UIBarButtonItem?
    var activityIndicatorBarButtonItem: UIBarButtonItem?
    var activityIndicatorView: UIActivityIndicatorView?
    var networkActivityIndicatorVisible: Bool = false {
        didSet {
            if networkActivityIndicatorVisible {
                AFNetworkActivityIndicatorManager.shared()?.incrementActivityCount()
            } else {
                AFNetworkActivityIndicatorManager.shared()?.decrementActivityCount()
            }
        }
    }
    var webViewTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.activityIndicatorView = activityIndicatorView
        activityIndicatorBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorBarButtonItem?.style = .bordered
        setProgressViewVisible(true)
        
        webView?.delegate = self
        webView?.scalesPageToFit = true
        if let url = stolperstein?.localizedBiographyURL {
            let request = URLRequest(url: url)
            webView?.loadRequest(request)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateActivityButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.diagnosticsService?.trackView(withClass: type(of: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        networkActivityIndicatorVisible = false
    }
    
    private func setProgressViewVisible(_ visible: Bool) {
        if visible {
            activityIndicatorView?.startAnimating()
            navigationItem.rightBarButtonItem = activityIndicatorBarButtonItem
        } else {
            activityIndicatorView?.stopAnimating()
            navigationItem.rightBarButtonItem = activityBarButtonItem
        }
    }
    
    private func updateActivityButton() {
        activityBarButtonItem?.isEnabled = (webViewTitle != nil && webView?.request?.url != nil)
    }
    
    @IBAction func showActivities(sender: UIBarButtonItem) {
        var itemsToShare: [Any?] = [webViewTitle, webView?.request?.url]
        var activities: [UIActivity] = [TUSafariActivity()]
        
        if let coordinate = stolperstein?.coordinate {
            let addressDict = [CNPostalAddressStreetKey: stolperstein?.locationStreet,
            CNPostalAddressCityKey: stolperstein?.locationCity,
                CNPostalAddressPostalCodeKey: stolperstein?.locationZIP].compactMapValues({ $0 })
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: addressDict))
            mapItem.name = stolperstein?.name
            
            itemsToShare.append(mapItem)
            activities.append(CCHMapsActivity())
        }
        
        let activityViewController = UIActivityViewController(activityItems: itemsToShare.compactMap({ $0 }), applicationActivities: activities)
        present(activityViewController, animated: true, completion: nil)
        
    }
}

extension DescriptionViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        webViewTitle = nil
        updateActivityButton()
        setProgressViewVisible(true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webViewTitle = webView.stringByEvaluatingJavaScript(from: "document.title")
        updateActivityButton()
        setProgressViewVisible(false)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        networkActivityIndicatorVisible = false
        setProgressViewVisible(false)
    }
}
