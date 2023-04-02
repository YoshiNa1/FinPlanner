//
//  List.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import RealmSwift

class ListCache: Object {
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var userUuid: String = "" // User().uuid
    var content = List<String>()
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(userUuid: String,
         content: Array<String>) {
        self.userUuid = userUuid
        self.content.append(objectsIn: content)
    }
}
