//
//  User.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation

public struct User {
    public var uuid: String = UUID().uuidString
    public var email: String
    public var password: String?
    public var isActivated: Bool = false
    public var accessToken: String?
    public var refreshToken: String?
    
    init(email: String,
         password: String) {
        self.email = email
        self.password = password
    }
    
    init(cache: UserCache) {
        self.uuid = cache.uuid
        self.email = cache.email
        self.password = cache.password
        self.isActivated = false
    }
    
    init(neUser: NEUser) {
        self.uuid = neUser.uuid
        self.email = neUser.email
        self.password = neUser.password
        self.isActivated = neUser.isActivated
        self.accessToken = neUser.accessToken
        self.refreshToken = neUser.refreshToken
    }
}
