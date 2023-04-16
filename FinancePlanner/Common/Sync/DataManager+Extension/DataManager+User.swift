//
//  DataManager+User.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension DataManager {
    
    func getUser(completion: @escaping (User?, Error?) -> Void) {
        syncManager.getUser(completion: completion)
    }
    
    func registration(user: User, completion: @escaping (User?, Error?) -> Void) {
        let neUser = NEUser(user)
        syncManager.registration(user: neUser) { _neUser, error in
            guard let neUser = _neUser else { return completion(nil, error) }
            let user = User(neUser: neUser)
            completion(user, error)
        }
    }
    
    func login(user: User, completion: @escaping (User?, Error?) -> Void) {
        let neUser = NEUser(user)
        syncManager.login(user: neUser) { _neUser, error in
            guard let neUser = _neUser else { return completion(nil, error) }
            let user = User(neUser: neUser)
            completion(user, error)
        }
    }
    
    func refresh(completion: @escaping (User?, Error?) -> Void) {
        syncManager.refresh { _neUser, error in
            guard let neUser = _neUser else { return completion(nil, error) }
            let user = User(neUser: neUser)
            completion(user, error)
        }
    }
    
    func logout(completion: @escaping (User?, Error?) -> Void) {
        syncManager.logout { _neUser, error in
            guard let neUser = _neUser else { return completion(nil, error) }
            let user = User(neUser: neUser)
            completion(user, error)
        }
    }
    
    func isUserExist(_ email: String, completion: @escaping (Bool, Error?) -> Void) {
        syncManager.isUserExist(email) { data, error in
            let isExists = data as? Bool
            completion(isExists ?? false, error)
        }
    }
}
