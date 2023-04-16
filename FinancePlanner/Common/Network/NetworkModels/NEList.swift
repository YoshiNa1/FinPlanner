//
//  NEList.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire
import ObjectMapper

struct NEList {
    let uuid: String
    let content: [String]
    
    init(cache: ListCache) {
        self.uuid = cache.uuid
        
        var cachedContent = [String]()
        cache.content.forEach { str in
            cachedContent.append(str)
        }
        self.content = cachedContent
    }
    
    init(_ model: FPList) {
        self.uuid = model.uuid
        self.content = model.content
    }
}

extension NEList: ImmutableMappable {
    enum CodingKeys: String {
        case uuid
        case content
    }
    
    public init(map: Map) throws {
        uuid = try map.value(CodingKeys.uuid.rawValue)
        content = try map.value(CodingKeys.content.rawValue)
    }
}
