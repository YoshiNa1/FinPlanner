//
//  SyncManager+Profile.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension SyncManager {
    
    func getProfile(completion: @escaping (Profile?, Error?) -> Void) {
        if Connectivity.isConnected() {
            ProfileRequests().get { profile, error in
                var complProfile: Profile?
                if let profile = profile {
                    complProfile = Profile(neProfile: profile)
                }
                completion(complProfile, error)
            }
        } else {
            if let cachedProfile = getCachedProfile() {
                let complProfile = Profile(cache: cachedProfile)
                completion(complProfile, nil)
            }
        }
    }
    
    func doProfileAction(_ action: SyncAction, profile: Profile, completion: @escaping (Profile?, Error?) -> Void) {
        let task = SyncTaskCache(profile: profile, actionType: action.rawValue)
        SyncTaskManager.instance.addTaskInQuery(task: task)
        
        let requestCompletion: (NEProfile?, Error?) -> Void = { profile, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let profile = profile {
                SyncTaskManager.instance.removeTaskFromQuery(task: task)
                
                let complProfile = Profile(neProfile: profile)
                self.cache(profile: complProfile, action: action)
                completion(complProfile, error)
            }
        }
        if Connectivity.isConnected() {
            let request = ProfileRequests()
            let profile = NEProfile(profile)
            switch action {
            case .createAction:
                request.create(profile: profile, completion: requestCompletion)
            case .editAction:
                request.update(profile: profile, completion: requestCompletion)
            case .deleteAction:
                request.delete(profile: profile, completion: requestCompletion)
            default: break
            }
        } else {
            self.cache(profile: profile, action: action)
            completion(profile, nil)
        }
        
    }
    
    private func getCachedProfile() -> ProfileCache? {
        if let profile = self.realm.objects(ProfileCache.self).first {
           return profile
        }
        return nil
    }
    
    private func cache(profile: Profile, action: SyncAction) {
        let profileCache = ProfileCache(profile)
        switch action {
        case .createAction:
            self.create(profile: profileCache)
        case .editAction:
            self.updateProfile(profile: profileCache)
        case .deleteAction:
            self.removeProfile()
        default: break
        }
    }
    
    private func create(profile: ProfileCache) {
        try! self.realm.write({
            self.realm.add(profile, update: .all)
        })
    }
    
    private func updateProfile(profile: ProfileCache) {
        try! self.realm.write({
            if let cachedProfile = getCachedProfile() {
                cachedProfile.currency = profile.currency
                cachedProfile.balance = profile.balance
                cachedProfile.savings = profile.savings
            }
        })
    }
    
    private func removeProfile() {
        try! self.realm.write({
            if let profile = getCachedProfile() {
                self.realm.delete(profile)
            }
        })
    }
}
