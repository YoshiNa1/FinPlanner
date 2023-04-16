//
//  ListRequest.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

enum ListEndpoint {
    case get
    case update(content:[String])
}

extension ListEndpoint: Endpoint {
    var path: String {
        return URL + "list/"
    }
    
    var method: HTTPMethod {
        var method: HTTPMethod = .get
        switch self {
        case .update:
            method = .put
        default:
            break
        }
        return method
    }
    
    
    var parameters: Parameters? {
        switch self {
        case .update(let content):
            return ["content" : content]
        default:
            return nil
        }
    }
    var headers: HTTPHeaders? {
        let accessToken = PreferencesStorage.shared.accessToken
        return HTTPHeaders([.authorization(bearerToken: accessToken)])
    }
    
}

