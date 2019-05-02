//
//  Items.swift
//  BCSwap
//
//  Created by Mark Lee on 4/24/19.
//  Copyright © 2019 Mark Lee. All rights reserved.
//

import Foundation
import Firebase

class Items {
    var itemsArray = [Item]()
    var db: Firestore!
    
    init () {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping() -> ()) {
        db.collection("items").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot  listener \(error!.localizedDescription)")
                return completed()
            }
            self.itemsArray = []
            // there are querySnapshot!.documents.count documents in the items snapshot
            for document in querySnapshot!.documents {
                let item = Item(dictionary: document.data())
                item.documentID = document.documentID
                self.itemsArray.append(item)
            }
            completed()
        }
    }
}
