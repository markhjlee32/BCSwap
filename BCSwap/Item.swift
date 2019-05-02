//
//  Item.swift
//  BCSwap
//
//  Created by Mark Lee on 4/24/19.
//  Copyright © 2019 Mark Lee. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class Item: NSObject, MKAnnotation {
    var name: String
    var price: String
    var contactInfo: String
    var address: String
    var pickupLocation: String
    var coordinate: CLLocationCoordinate2D
    var postingUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var  title: String? {
        return address
    }
    
    var subtitle: String? {
        return pickupLocation
    }
    
    var dictionary: [String: Any] {
        return ["name": name, "price": price, "contactInfo": contactInfo, "address": address, "pickupLocation": pickupLocation, "longitude": longitude, "latitude": latitude, "postingUserID": postingUserID]
    }
    
    init(name: String, price: String, contactInfo: String, pickupLocation: String, address: String, coordinate: CLLocationCoordinate2D, postingUserID: String, documentID: String) {
        self.name = name
        self.price = price
        self.contactInfo = contactInfo
        self.address = address
        self.pickupLocation = pickupLocation
        self.coordinate = coordinate
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience override init() {
        self.init(name: "", price: "", contactInfo: "", pickupLocation: "", address: "", coordinate: CLLocationCoordinate2D(), postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let price = dictionary["price"] as! String? ?? ""
        let contactInfo = dictionary["contactInfo"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let pickupLocation = dictionary["pickupLocation"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.init(name: name, price: price, contactInfo: contactInfo, pickupLocation: pickupLocation, address: address, coordinate: coordinate, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the userID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("items").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // Let Firestore create the new documentID
            ref = db.collection("items").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("*** ERROR: creating new document \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("New document created with ref ID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
        }
    }
}

