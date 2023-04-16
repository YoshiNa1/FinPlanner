//
//  SyncManager+User.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation
extension SyncManager {
    
    func getUser(completion: @escaping (User?, Error?) -> Void) {
        var complUser: User?
        if Connectivity.isConnected() {
            UserRequests().get { user, error in
                if let user = user {
                    complUser = User(neUser: user)
                }
                completion(complUser, error)
            }
        } else {
            if let user = self.realm.objects(UserCache.self).first {
                complUser = User(cache: user)
                completion(complUser, nil)
            }
        }
    }
    
    func registration(user: NEUser, completion: @escaping (NEUser?, Error?) -> Void) {
        UserRequests().registration(user: user, completion: completion)
    }
    
    func login(user: NEUser, completion: @escaping (NEUser?, Error?) -> Void) {
        UserRequests().login(user: user, completion: completion)
    }
    
    func logout(completion: @escaping (NEUser?, Error?) -> Void) {
        UserRequests().logout(completion: completion)
    }
    
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (NEUser?, Error?) -> Void) {
        UserRequests().changePassword(oldPassword: oldPassword, newPassword: newPassword, completion: completion)
    }
    
    func refresh(completion: @escaping (NEUser?, Error?) -> Void) {
        UserRequests().refresh(completion: completion)
    }
    
    func isUserExist(_ email: String, completion: @escaping (Any?, Error?) -> Void) {
        UserRequests().isUserExist(email, completion: completion)
    }
}
