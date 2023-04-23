//
//  NEUser.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire
import ObjectMapper

struct NEUser {
    var uuid: String
    var email: String
    var password: String?
    var isActivated: Bool
    var accessToken: String?
    var refreshToken: String?
    
    init(cache: UserCache) {
        self.uuid = cache.uuid
        self.email = cache.email
        self.password = cache.password
        self.isActivated = false
    }
    
    init(_ model: User) {
        self.uuid = model.uuid
        self.email = model.email
        self.password = model.password
        self.isActivated = false
    }
    
    
}

extension NEUser : ImmutableMappable {
    enum CodingKeys: String {
        case uuid
        case email
        case password
        case user
        case isActivated
        case accessToken
        case refreshToken
    }
      
    public init(map: Map) throws {
        accessToken = try map.value(CodingKeys.accessToken.rawValue)
        refreshToken = try map.value(CodingKeys.refreshToken.rawValue)
        let user: [String : Any]? = try? map.value(CodingKeys.user.rawValue)
        uuid = try map.value(CodingKeys.uuid.rawValue) ?? user?[CodingKeys.uuid.rawValue] as? String ?? ""
        email = try map.value(CodingKeys.email.rawValue) ?? user?[CodingKeys.email.rawValue] as? String ?? ""
        isActivated = try map.value(CodingKeys.isActivated.rawValue) ?? user?[CodingKeys.isActivated.rawValue] as? Bool ?? false
        password = try? map.value(CodingKeys.password.rawValue)
    }
    
    mutating func mapping(map: Map) { // .toJSON()
        email >>> map[CodingKeys.email.rawValue]
        password >>> map[CodingKeys.password.rawValue]
    }
}
