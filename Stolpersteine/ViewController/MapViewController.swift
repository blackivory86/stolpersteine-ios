//
//  MapViewController.swift
//  Stolpersteine
//
//  Created by Jan Rose on 07.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    private enum Constants {
        static let ZoomDistanceUser: CLLocationDistance = 1200
        static let ZoomDistanceStolperStein: CLLocationDistance = ZoomDistanceUser * 0.25
    }
    
    @IBOutlet private weak var mapView: MKMapView?
    @IBOutlet private weak var infoButton: UIButton?
    @IBOutlet private weak var locationBarButtonItem: UIBarButtonItem?
    @IBOutlet private weak var mapSearchDisplayController: MapSearchDisplayController?
    private let locationManager = CLLocationManager()
    private var displayRegionIcon: Bool = false
    private let syncController = StolpersteineSynchronizationController(withNetworkService: AppDelegate.networkService!)
    private var mapClusterController: CCHMapClusterController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("MapViewController.title", comment: "")
        mapView?.showsBuildings = true
        infoButton?.accessibilityLabel = NSLocalizedString("MapViewController.info", comment: "")
        
        // Clustering
        mapClusterController = CCHMapClusterController(mapView: mapView)
        mapClusterController?.delegate = self
        
        // Navigation bar
        mapSearchDisplayController?.networkService = AppDelegate.networkService
        mapSearchDisplayController?.mapClusterController = mapClusterController
        mapSearchDisplayController?.zoomDistance = Constants.ZoomDistanceStolperStein
        mapSearchDisplayController?.delegate = mapSearchDisplayController
        mapSearchDisplayController?.searchResultsDataSource = mapSearchDisplayController
        mapSearchDisplayController?.searchResultsDelegate = mapSearchDisplayController
        
        mapSearchDisplayController?.searchBar.removeFromSuperview()
        mapSearchDisplayController?.displaysSearchBarInNavigationBar = true
        mapSearchDisplayController?.navigationItem?.rightBarButtonItem = locationBarButtonItem
        mapSearchDisplayController?.searchBar.placeholder = NSLocalizedString("MapViewController.searchBarPlaceholder", comment: "")
        updateSearchBarForInterfaceOrientation(interfaceOrientation)
        
        // User location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Start loading data
        syncController.delegate = self
        
        // Initialize map region
        if let region = AppDelegate.configurationService?.coordinateRegion(forKey: .VisibleRegion) {
            mapView?.region = region
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        syncController.synchronize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #warning("Re-enable tracking")
//        [AppDelegate.diagnosticsService trackViewWithClass:self.class];
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.syncController.synchronize()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        updateSearchBarForInterfaceOrientation(toInterfaceOrientation)
        
        super.willRotate(to: toInterfaceOrientation, duration: duration)
    }
    
    private func updateSearchBarForInterfaceOrientation(_ orientation: UIInterfaceOrientation) {
        let imageName = orientation.isLandscape ? "SearchBarBackgroundLandscape" : "SearchBarBackground"
        searchDisplayController?.searchBar.setSearchFieldBackgroundImage(UIImage(named: imageName), for: .normal)
    }
    
    private func updateLocationBarButtonItem() {
        if !CLLocationManager.locationServicesEnabled() || !CLLocationManager.isAuthorized() {
            displayRegionIcon = true
        }
        
        let imageName = displayRegionIcon ? "IconRegion" : "IconLocation"
        locationBarButtonItem?.image = UIImage(named: imageName)
        let labelKey = displayRegionIcon ? "MapViewController.region" : "MapViewController.location"
        locationBarButtonItem?.accessibilityLabel = NSLocalizedString(labelKey, comment: "")
    }
    
    @IBAction private func centerMap(sender: UIBarButtonItem) {
        guard let mapView = mapView else { return }
        
        displayRegionIcon.toggle()
        
        let region: MKCoordinateRegion? = {
            if displayRegionIcon {
                return MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: Constants.ZoomDistanceUser, longitudinalMeters: Constants.ZoomDistanceUser)
            } else {
                return AppDelegate.configurationService?.coordinateRegion(forKey: .VisibleRegion)
            }
        }()
        if let region = region {
            mapView.setRegion(region, animated: true)
        }
        
        updateLocationBarButtonItem()
        
        #warning("adapt after diagnosticsservice is converted")
//        let diagnosticsLabel = displayRegionIcon ? "userLocation" : "region"
//        AppDelegate.diagnosticsService?.trackEvent(DiagnosticsServiceEventMapCentered, with: self.class, label: diagnosticsLabel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapViewControllerToStolpersteineCardsViewController" {
            if let mapView = mapView,
                let selectedClusterAnnotation = mapView.selectedAnnotations.last as? CCHMapClusterAnnotation,
                let listViewController = segue.destination as? CardsViewController {
                listViewController.stolpersteine = Array(selectedClusterAnnotation.annotations) as! [Stolperstein]
                listViewController.title = selectedClusterAnnotation.stolpersteineCount
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation,
            annotation.isKind(of: CCHMapClusterAnnotation.self) else { return }
        
        performSegue(withIdentifier: "mapViewControllerToStolpersteineCardsViewController", sender: self)
    }
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isKind(of: CCHMapClusterAnnotation.self) else { return nil }
        
        let annotationView: MapClusterAnnotationView = {
            if let clusterAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stolpersteinCluster") as? MapClusterAnnotationView {
                clusterAnnotationView.annotation = annotation
                return clusterAnnotationView
            } else {
                let clusterAnnotationView = MapClusterAnnotationView(annotation: annotation,
                                                                     reuseIdentifier: "stolpersteinCluster")
                clusterAnnotationView.canShowCallout = true
                
                let rightButton = UIButton(type: .detailDisclosure)
                
                #warning("test if this workaround is still necessary")
//                if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
//                    // Workaround for misaligned button, see http://stackoverflow.com/questions/25484608/ios-8-mkannotationview-rightcalloutaccessoryview-misaligned
//                    CGRect frame = rightButton.frame;
//                    frame.size.height = 55;
//                    frame.size.width = 55;
//                    rightButton.frame = frame;
//                }
                
                clusterAnnotationView.rightCalloutAccessoryView = rightButton
                
                return clusterAnnotationView
            }
        }()
        
        if let mapClusterAnnotation = annotation as? CCHMapClusterAnnotation {
            annotationView.count = mapClusterAnnotation.annotations.count
            annotationView.isOneLocation = mapClusterAnnotation.isUniqueLocation()
        }
        
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse:
            mapView?.showsUserLocation = true
            locationManager.startUpdatingLocation()
        default:
            mapView?.showsUserLocation = false
            locationManager.stopUpdatingLocation()
        }
        
        updateLocationBarButtonItem()
    }
}

extension MapViewController: CCHMapClusterControllerDelegate {
    func mapClusterController(_ mapClusterController: CCHMapClusterController!,
                              willReuse mapClusterAnnotation: CCHMapClusterAnnotation!) {
        let annotationView = mapClusterController.mapView.view(for: mapClusterAnnotation) as? MapClusterAnnotationView
        annotationView?.count = mapClusterAnnotation.annotations.count
        annotationView?.isOneLocation = mapClusterAnnotation.isUniqueLocation()
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!,
                              titleFor mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
        mapClusterAnnotation.stolpersteineTitle
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!,
                              subtitleFor mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
        mapClusterAnnotation.stolpersteineSubtitle
    }
}

extension MapViewController: StolpersteineSynchronizationControllerDelegate {
    func controller(_ controller: StolpersteineSynchronizationController,
                    didAddStolpersteine stolpersteine: [Stolperstein]) {
        mapClusterController?.addAnnotations(stolpersteine, withCompletionHandler: nil)
    }
    
    func controller(_ controller: StolpersteineSynchronizationController, didRemoveStolpersteine: [Stolperstein]) {
        #warning("This needs to be implemented later")
    }
}

extension CLLocationManager {
    static func isAuthorized() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
}

class MapClusterAnnotationView: MKAnnotationView {
    var count: Int = 1 {
        didSet {
            countLabel.text = "\(count)"
            setNeedsLayout()
        }
    }
    var isOneLocation: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    let countLabel: UILabel
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        countLabel = UILabel(frame: .zero)
        countLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        countLabel.textAlignment = .center
        countLabel.backgroundColor = .clear
        countLabel.textColor = UIColor(white: (244.0/255.0), alpha: 1.0)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 2
        countLabel.numberOfLines = 1
        countLabel.font = .boldSystemFont(ofSize: 12)
        countLabel.baselineAdjustment = .alignCenters
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        countLabel.frame = bounds
        addSubview(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let (image, centerOffset): (UIImage?, CGPoint) = {
            if isOneLocation {
                let image = UIImage(named: "MarkerSquare")
                let centerOffset = CGPoint(x: 0, y: (image?.size.height ?? 0) * 0.5)
                var frame = bounds
                frame.origin.y -= 2
                countLabel.frame = frame
                
                return (image, centerOffset)
            } else {
                countLabel.frame = bounds
                
                let offSet = CGPoint.zero
                switch count {
                case 999...:
                    return (UIImage(named: "MarkerCircle94"), offSet)
                case 499...:
                    return (UIImage(named: "MarkerCircle90"), offSet)
                case 99...:
                    return (UIImage(named: "MarkerCircle84"), offSet)
                case 9...:
                    return (UIImage(named: "MarkerCircle62"), offSet)
                default:
                    return (UIImage(named: "MarkerCircle52"), offSet)
                }
            }
        }()
        
        self.image = image
        self.centerOffset = centerOffset
    }
}
