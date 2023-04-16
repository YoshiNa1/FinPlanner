//
//  List.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation

public struct FPList {
    public var uuid: String
    public var content: [String]
    
    init(cache: ListCache) {
        self.uuid = cache.uuid
        
        var cachedContent = [String]()
        cache.content.forEach { str in
            cachedContent.append(str)
        }
        self.content = cachedContent
    }
    
    init(neList: NEList) {
        self.uuid = neList.uuid
        self.content = neList.content
    }
}
