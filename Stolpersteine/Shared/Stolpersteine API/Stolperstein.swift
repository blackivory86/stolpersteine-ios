//
//  Stolperstein.swift
//  Stolpersteine
//
//  Created by Jan Rose on 04.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import MapKit

enum StolpersteinType: Int {
    case stein
    case schwelle
}

@objc
public class Stolperstein: NSObject, MKAnnotation, NSCoding, NSCopying {
    
    let ID: String?
    public let title: String?
    public let subtitle: String?
    let stolpersteinType: StolpersteinType?
    let sourceName: String?
    let sourceURL: URL?
    let personFirstName: String?
    let personLastName: String?
    public let biographyURL: URL?
    @objc let locationStreet: String?
    @objc let locationZIP: String?
    @objc let locationCity: String?
    public let coordinate: CLLocationCoordinate2D
    
    init(id: String?,
         stolpersteinType: StolpersteinType,
         sourceName: String?,
         sourceURL: URL?,
         personFirstName: String?,
         personLastName: String?,
         biographyURL: URL?,
         locationStreet: String?,
         locationZIP: String?,
         locationCity: String?,
         locationCoordinate: CLLocationCoordinate2D) {
        self.ID = id
        self.title = nil
        self.subtitle = nil
        self.stolpersteinType = stolpersteinType
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.personFirstName = personFirstName
        self.personLastName = personLastName
        self.biographyURL = biographyURL
        self.locationStreet = locationStreet
        self.locationZIP = locationZIP
        self.locationCity = locationCity
        self.coordinate = locationCoordinate
    }
    
    public required init?(coder: NSCoder) {
        self.ID = coder.decodeObject(forKey: "ID") as? String
        self.stolpersteinType = StolpersteinType(rawValue: coder.decodeInteger(forKey: "type"))
        self.sourceName = coder.decodeObject(forKey: "sourceName") as? String
        self.sourceURL = coder.decodeObject(forKey: "sourceURL") as? URL
        self.personFirstName = coder.decodeObject(forKey: "personFirstName") as? String
        self.personLastName = coder.decodeObject(forKey: "personLastName") as? String
        self.biographyURL = coder.decodeObject(forKey: "personBiographyURL") as? URL
        self.locationStreet = coder.decodeObject(forKey: "locationStreet") as? String
        self.locationZIP = coder.decodeObject(forKey: "locationZipCode") as? String
        self.locationCity = coder.decodeObject(forKey: "locationCity") as? String
        
        self.coordinate = CLLocationCoordinate2D(latitude: coder.decodeDouble(forKey: "locationCoordinate.latitude"),
                                                 longitude: coder.decodeDouble(forKey: "locationCoordinate.longitude"))
        
        self.title = nil
        self.subtitle = nil
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.ID, forKey: "ID")
        coder.encode(self.stolpersteinType, forKey: "type")
        coder.encode(self.sourceURL, forKey: "sourceURL")
        coder.encode(self.sourceName, forKey: "sourceName")
        coder.encode(self.personFirstName, forKey: "personFirstName")
        coder.encode(self.personLastName, forKey: "personLastName")
        coder.encode(self.biographyURL, forKey: "personBiographyURL")
        coder.encode(self.locationStreet, forKey: "locationStreet")
        coder.encode(self.locationZIP, forKey: "locationZipCode")
        coder.encode(self.locationCity, forKey: "locationCity")
        coder.encode(self.coordinate.latitude, forKey: "locationCoordinate.latitude")
        coder.encode(self.coordinate.longitude, forKey: "locationCoordinate.longitude")
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return self // immutable
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? NSObject else { return false }
        
        if let otherStolperstein = object as? Stolperstein {
            return self.ID == otherStolperstein.ID
        } else {
            return false
        }
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(ID)
        return hasher.finalize()
    }
}

extension Stolperstein {
    @objc convenience public init?(fromDict dict: [String: Any]) {
        let source = dict["source"] as? [String: Any]
        let person = dict["person"] as? [String: Any]
        let location = dict["person"] as? [String: Any]
        
        let rawType = dict["type"] as? String
        let rawSourceURL = source?["url"] as? String
        let sourceURL = URL(string: rawSourceURL ?? "")
        let rawBioURL = person?["biographyUrl"] as? String
        let bioURL = URL(string: rawBioURL ?? "")
        
        guard let coordinates = location?["coordinates"] as? [String: Any],
            let latRaw = coordinates["latitude"] as? String,
            let longRaw = coordinates["longitude"] as? String,
            let lat = Double(latRaw), let long = Double(longRaw) else {
                return nil
        }
        
        
        self.init(id: dict["id"] as? String,
                  stolpersteinType: (rawType == "stolperschwelle") ? .schwelle : .stein,
                  sourceName: source?["name"] as? String,
                  sourceURL: sourceURL,
                  personFirstName: person?["firstName"] as? String,
                  personLastName: person?["lastName"] as? String,
                  biographyURL: bioURL,
                  locationStreet: location?["street"] as? String,
                  locationZIP: location?["zipCode"] as? String,
                  locationCity: location?["city"] as? String,
                  locationCoordinate: CLLocationCoordinate2DMake(lat, long))
    }
}
