//
//  ProfileRequest.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

enum ProfileEndpoint {
    case create(profile: NEProfile) // const {balance, savings, currency}
    case get
    case update(profile: NEProfile) // const {balance, savings, currency}
    case delete
}

extension ProfileEndpoint : Endpoint {
    var path: String {
        return URL + "profile/"
    }
    
    var method: HTTPMethod {
        var method: HTTPMethod = .get
        switch self {
        case .create:
            method = .post
        case .update:
            method = .put
        case .delete:
            method = .delete
        default:
            break
        }
        return method
    }
    
    var parameters: Parameters? {
        switch self {
        case .create(let profile), .update(let profile):
            return profile.toJSON()
        default:
            return nil
        }
    }
    var headers: HTTPHeaders? {
        let accessToken = PreferencesStorage.shared.accessToken
        return HTTPHeaders([.authorization(bearerToken: accessToken)])
    }
    
}
