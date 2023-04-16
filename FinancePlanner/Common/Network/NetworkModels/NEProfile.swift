//
//  NEProfile.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire
import ObjectMapper

struct NEProfile {
    let uuid: String
    let balance: Double
    let savings: Double
    let currency: String
  
    init(cache: ProfileCache) {
        self.uuid = cache.uuid
        self.balance = cache.balance
        self.savings = cache.savings
        self.currency = cache.currency
    }
    
    init(_ model: Profile) {
        self.uuid = model.uuid
        self.balance = model.balance
        self.savings = model.savings
        self.currency = model.currency
    }
}
extension NEProfile : ImmutableMappable {
    
    enum CodingKeys: String {
        case uuid
        case balance
        case savings
        case currency
    }
    
    public init(map: Map) throws {
        uuid = try map.value(CodingKeys.uuid.rawValue)
        balance = try map.value(CodingKeys.balance.rawValue)
        savings = try map.value(CodingKeys.savings.rawValue)
        currency = try map.value(CodingKeys.currency.rawValue)
    }
    
    mutating func mapping(map: Map) { // .toJSON()
        balance >>> map[CodingKeys.balance.rawValue]
        savings >>> map[CodingKeys.savings.rawValue]
        currency >>> map[CodingKeys.currency.rawValue]
    }
}
