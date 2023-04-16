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
    var content = List<String>()
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(content: Array<String>) {
        self.content.append(objectsIn: content)
    }
    
    init(neModel: NEList) {
        self.uuid = neModel.uuid
        self.content.append(objectsIn: neModel.content)
    }
    
    init(_ list: FPList) {
        self.uuid = list.uuid
        
        var content = List<String>()
        list.content.forEach { str in
            content.append(str)
        }
        self.content = content
    }
}
