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

enum SyncAction: Int {
    case getAction
//    case getAllAction
    case createAction
    case editAction
    case deleteAction
}

class SyncManager {
    let realm = try! Realm()
    
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
//        self.loadList() // TODO: moved to homePage
    }
    
}
