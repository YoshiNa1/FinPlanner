//
//  NoteRequest.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

enum NoteEndpoint {
    case create(date: String, content: String)
    case get(date: String)
    case getAll
    case update(date: String, content: String)
    case delete(date: String)
}

extension NoteEndpoint: Endpoint {
    var path: String {
        switch self {
        case .get(let date), .update(let date, _), .delete(let date):
            return URL + "note/" + "\(date)"
        default:
            return URL + "note"
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
        case .create(let date, let content):
            return ["date": date, "content": content]
        case .update(_, let content):
            return ["content": content]
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        let accessToken = PreferencesStorage.shared.accessToken
        return HTTPHeaders([.authorization(bearerToken: accessToken)])
    }
    
}
