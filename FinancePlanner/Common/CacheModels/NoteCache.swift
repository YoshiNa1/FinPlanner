//
//  Note.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import RealmSwift

class NoteCache: Object {
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var userUuid: String = "" // User().uuid
    @objc dynamic var date: Date = Date()
    @objc dynamic var descrpt: String = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(userUuid: String,
         date: Date,
         description: String) {
        self.userUuid = userUuid
        self.date = date
        self.descrpt = description
    }
}
