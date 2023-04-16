//
//  ProfileRequests.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation
import Alamofire

class ProfileRequests {
    private var requestManager: RequestManager {
        return RequestManager.instance
    }

    private func sendRequest(_ endpoint: ProfileEndpoint, completion: @escaping (NEProfile?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }

    func create(profile: NEProfile, completion: @escaping (NEProfile?, Error?) -> Void) {
        sendRequest(.create(profile: profile), completion: completion)
    }
    
    func update(profile: NEProfile, completion: @escaping (NEProfile?, Error?) -> Void) {
        sendRequest(.update(profile: profile), completion: completion)
    }
    
    func get(completion: @escaping (NEProfile?, Error?) -> Void) {
        sendRequest(.get, completion: completion)
    }
    
    func delete(profile: NEProfile, completion: @escaping (NEProfile?, Error?) -> Void) {
        sendRequest(.delete, completion: completion)
    }
    
}
