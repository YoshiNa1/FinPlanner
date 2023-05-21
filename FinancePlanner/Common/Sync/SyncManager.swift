//
//  SyncManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import RealmSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

public let fpSyncState = "syncState"

public extension Notification.Name {
    static let syncStatusChanged = Notification.Name("syncStatusChanged")
}

public enum SyncStatus: Int{
    case notSynced = 0
    case synced
    case syncInProgress
}

enum SyncAction: Int {
    case getAction
//    case getAllAction
    case createAction
    case editAction
    case deleteAction
}

class SyncManager {
    let realm = try! Realm()
    private(set) public var syncState: SyncStatus = .synced
    
    private var user: User? {
        var retUser: User?
        self.getUser { user, error in
            retUser = user
        }
        return retUser
    }
    private var profile: Profile? {
        var retProfile: Profile?
        self.getProfile { profile, error in
            retProfile = profile
        }
        return retProfile
    }
    private var items: [Item]? {
        var retItems = [Item]()
        self.getAllItems { items, error in
            retItems = items
        }
        return retItems
    }
    
    private var notes: [Note]? {
        var retNotes = [Note]()
        self.getAllNotes { notes, error in
            retNotes = notes
        }
        return retNotes
    }
    
    var list : Array<String> = Array<String>()
    
    public init() {
        self.loadList() // don't remove!
    }
    
    func syncAllData(completion: @escaping (Error?) -> Void) {
        if Connectivity.isConnected() {
            let group = DispatchGroup()
            
            postSyncNotification(status: .syncInProgress)
            
            SyncTaskManager.instance.doTasksFromQuery {
                try! self.realm.write({
                    let syncTaskCache = self.realm.objects(SyncTaskCache.self)
                    self.realm.delete(syncTaskCache)
                })
                
                group.enter()
                UserRequests().get { user, error in
                    try! self.realm.write({
                        // clear old cache
                        let userCache = self.realm.objects(UserCache.self)
                        self.realm.delete(userCache)
                        // cache new data
                        if let user = user {
                            let userCache = UserCache(neModel: user)
                            self.realm.add(userCache, update: .all)
                        } else {
                            completion(error)
                        }
                    })
                    group.leave()
                }
                
                group.enter()
                ProfileRequests().getProfile { profile, error in
                    try! self.realm.write({
                        // clear old cache
                        let profileCache = self.realm.objects(ProfileCache.self)
                        self.realm.delete(profileCache)
                        // cache new data
                        if let profile = profile {
                            let profileCache = ProfileCache(neModel: profile)
                            self.realm.add(profileCache, update: .all)
                        } else {
                            completion(error)
                        }
                    })
                    group.leave()
                }
                
                group.enter()
                ListRequests().update(content: self.list) { list, error in //TODO: ХУЕТА, ЭТО НЕ РАБОТАЕТ ПРИ ОЧИСТКЕ КЭША (удаление приложа)
                    try! self.realm.write({
                        // clear old cache
                        let listCache = self.realm.objects(ListCache.self)
                        self.realm.delete(listCache)
                        // cache new data
                        if let list = list {
                            let listCache = ListCache(neModel: list)
                            self.realm.add(listCache, update: .all)
                        }
                    })
                    group.leave()
                }
                
                group.enter()
                NoteRequests().getAll { notes, error in
                    try! self.realm.write({
                        // clear old cache
                        let notesCache = self.realm.objects(NoteCache.self)
                        self.realm.delete(notesCache)
                        // cache new data
                        if let notes = notes {
                            notes.forEach { note in
                                let noteCache = NoteCache(neModel: note)
                                self.realm.add(noteCache, update: .all)
                            }
                        } else {
                            completion(error)
                        }
                    })
                    group.leave()
                }
                
                group.enter()
                ItemRequests().getAll { items, error in
                    try! self.realm.write({
                        // clear old cache
                        let itemsCache = self.realm.objects(ItemCache.self)
                        self.realm.delete(itemsCache)
                        // cache new data
                        if let items = items {
                            items.forEach { item in
                                let itemCache = ItemCache(neModel: item)
                                self.realm.add(itemCache, update: .all)
                            }
                        } else {
                            completion(error)
                        }
                    })
                    group.leave()
                }
                
                group.notify(queue: DispatchQueue.main) {
                    self.postSyncNotification(status: .synced)
                    completion(nil)
                }
            }
        } else {
            //TODO: SOMETHING. POST SYNC STATUS
            postSyncNotification(status: .notSynced)
            completion(nil)
        }
    }
    
    func refreshSyncState() {
        if !Connectivity.isConnected() {
            postSyncNotification(status: .notSynced)
        }
    }
    
    private func postSyncNotification(status: SyncStatus) {
        syncState = status
        NotificationCenter.default.post(name: .syncStatusChanged,
                                        object: self,
                                        userInfo: [fpSyncState: status])
    }
}
