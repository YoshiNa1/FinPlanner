//
//  NENote.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire
import ObjectMapper

struct NENote {
    let uuid: String
    let date: String
    let content: String
    
    init(cache: NoteCache) {
        self.uuid = cache.uuid
        let date = cache.date
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from:date)
        self.date = dateString
        self.content = cache.content
    }
    
    init(_ model: Note) {
        self.uuid = model.uuid
        let date = model.date
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from:date)
        self.date = dateString
        self.content = model.content
    }
    
}

extension NENote: ImmutableMappable {
    enum CodingKeys: String {
        case uuid
        case date
        case content
    }
    
    public init(map: Map) throws {
        uuid = try map.value(CodingKeys.uuid.rawValue)
        content = try map.value(CodingKeys.content.rawValue)
        date = try map.value(CodingKeys.date.rawValue)
    }
}

