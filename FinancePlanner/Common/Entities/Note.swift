//
//  Note.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation

public struct Note {
    public var uuid: String = UUID().uuidString
    public var date: Date
    public var content: String
    
    init(date: Date,
         content: String) {
        self.date = date
        self.content = content
    }
    
    init(neNote: NENote) {
        self.uuid = neNote.uuid
        let dateString = neNote.date
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime,
                                       .withDashSeparatorInDate,
                                       .withFullDate,
                                       .withFractionalSeconds,
                                       .withColonSeparatorInTimeZone]
        let date = dateFormatter.date(from:dateString) ?? Date()
        self.date = date
        self.content = neNote.content
    }
    
    init(cache: NoteCache) {
        self.uuid = cache.uuid
        self.date = cache.date
        self.content = cache.content
    }
}
