//
//  Word.swift
//  eWords
//
//  Created by Марченко Вадим on 02.01.2019.
//  Copyright © 2019 Vadim Marchenko. All rights reserved.
//

import Foundation
import Firebase

struct Word {
    
    let title: String
    let userId: String
    let translation: String
    let ref: DatabaseReference?
    
    init(title: String, translation: String, userId: String) {
        self.title = title
        self.userId = userId
        self.translation = translation
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        title = snapshotValue["title"] as! String
        translation = snapshotValue["translation"] as! String
        userId = snapshotValue["userId"] as! String
        ref = snapshot.ref
        
    }
    
    func convertToDictionary() -> Any {
        return ["title": title, "translation": translation, "userId": userId]
    }
}
