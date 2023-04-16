//
//  UserRequests.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation
import Alamofire

class UserRequests {
    private var requestManager: RequestManager {
        return RequestManager.instance
    }

    private func sendRequest(_ endpoint: UserEndpoint, completion: @escaping (NEUser?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }
    
    private func sendRequest(_ endpoint: UserEndpoint, completion: @escaping (Any?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }
    
    func registration(user: NEUser, completion: @escaping (NEUser?, Error?) -> Void) {
        sendRequest(.registration(user: user), completion: completion)
    }
    
    func login(user: NEUser, completion: @escaping (NEUser?, Error?) -> Void) {
        sendRequest(.login(user: user), completion: completion)
    }
    
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (NEUser?, Error?) -> Void) {
        sendRequest(.changePassword(oldPassword: oldPassword, newPassword: newPassword), completion: completion)
    }
    
    func logout(completion: @escaping (NEUser?, Error?) -> Void) {
        sendRequest(.logout, completion: completion)
    }
    
    func refresh(completion: @escaping (NEUser?, Error?) -> Void) {
        sendRequest(.refresh, completion: completion)
    }
    
    func get(completion: @escaping (NEUser?, Error?) -> Void) {
        sendRequest(.get, completion: completion)
    }
    
    func isUserExist(_ email: String, completion: @escaping (Any?, Error?) -> Void) {
        sendRequest(.isUserExist(email: email), completion: completion)
    }
    
    func delete(completion: @escaping (NEUser?, Error?) -> Void) {
        sendRequest(.delete, completion: completion)
    }
    
}
