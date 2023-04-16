//
//  UserRequest.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

enum UserEndpoint {
    case registration(user: NEUser) // const {email, password, role}
    case login(user: NEUser) // const {email, password}
    case logout
    case refresh
    case get
    case isUserExist(email: String)
    case delete
    case changePassword(oldPassword: String, newPassword: String) // const {oldPassword, newPassword}
}

extension UserEndpoint: Endpoint {
    var path: String {
        var path = URL + "user/"
        switch self {
        case .registration:
            path += "registration"
        case .login:
            path += "login"
        case .logout:
            path += "logout"
        case .refresh:
            path += "refresh"
        case .changePassword:
            path += "changePassword"
        case .isUserExist(let email):
            path += "\(email)"
        default:
            break
        }
        return path
    }
    
    var method: HTTPMethod {
        var method: HTTPMethod = .post
        switch self {
        case .get, .isUserExist, .refresh:
            method = .get
        case .delete:
            method = .delete
        case .changePassword:
            method = .put
        default:
            break
        }
        return method
    }
    
    var parameters: Parameters? {
        switch self {
//        case .registration(let user), .login(let user):
        case .registration(let user):
            return user.toJSON()
        case .login(let user):
            var params = [String:String]()
            params["email"] = user.email
            params["password"] = user.password
            return params
        case .changePassword(let oldPassword, let newPassword):
            var params = [String:String]()
            params["oldPassword"] = oldPassword
            params["newPassword"] = newPassword
            return params
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .logout, .refresh, .get, .delete, .changePassword:
            let accessToken = PreferencesStorage.shared.accessToken
            return HTTPHeaders([.authorization(bearerToken: accessToken)])
        default:
            return nil
        }
    }

}
