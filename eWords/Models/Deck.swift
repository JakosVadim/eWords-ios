//
//  Desk.swift
//  eWords
//
//  Created by Марченко Вадим on 30.12.2018.
//  Copyright © 2018 Vadim Marchenko. All rights reserved.
//

import Foundation
import Firebase

struct Deck {
    let title: String
    let userId: String
    let ref: DatabaseReference?
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        ref = snapshot.ref
        
    }
    
    func convertToDictionary() -> Any {
        return ["title": title, "userId": userId]
    }
}
