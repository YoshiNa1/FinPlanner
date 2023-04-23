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
    @objc dynamic var date: Date = Date()
    @objc dynamic var content: String = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(date: Date,
         content: String) {
        self.date = date
        self.content = content
    }
    
    init(neModel: NENote) {
        self.uuid = neModel.uuid
        let dateString = neModel.date
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime,
                                       .withDashSeparatorInDate,
                                       .withFullDate,
                                       .withFractionalSeconds,
                                       .withColonSeparatorInTimeZone]
        let date = dateFormatter.date(from:dateString) ?? Date()
        self.date = date
        self.content = neModel.content
    }
    
    init(_ model: Note) {
        self.uuid = model.uuid
        self.date = model.date
        self.content = model.content
    }
}
