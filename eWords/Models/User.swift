//
//  User.swift
//  eWords
//
//  Created by Марченко Вадим on 30.12.2018.
//  Copyright © 2018 Vadim Marchenko. All rights reserved.
//

import Foundation
import Firebase

struct UserData {
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
