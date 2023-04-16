//
//  ItemRequest.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

enum ItemEndpoint {
    case create(item: NEItem) // const {type, isIncome, name, description, category, amount, currency}
    case get(uuid: String)
    case getAll
    case update(uuid: String, item: NEItem) // const {type, isIncome, name, description, category, amount, currency}
    case delete(uuid: String)
}

extension ItemEndpoint: Endpoint {
    var path: String {
        switch self {
        case .get(let uuid), .update(let uuid, _), .delete(let uuid):
            return URL + "item/" + "\(uuid)"
        default:
            return URL + "item"
        }
        
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
        case .create(let item), .update(_, let item):
            let json = item.toJSON()
            return json
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        let accessToken = PreferencesStorage.shared.accessToken
        return HTTPHeaders([.authorization(bearerToken: accessToken)])
    }
    
}
