//
//  User.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import RealmSwift

class UserCache: Object {
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var email: String = ""
    @objc dynamic var password: String? = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(email: String,
         password: String) {
        self.email = email
        self.password = password
    }
    
    init(neModel: NEUser) {
        self.uuid = neModel.uuid
        self.email = neModel.email
        self.password = neModel.password
    }
}
