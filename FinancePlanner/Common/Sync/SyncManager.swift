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
    
    var defaultCurrency: String {
        get { PreferencesStorage.shared.defaultCurrency?.name ?? ""}
    }
    var user: User!
    var profile: Profile!
    var items: [Item] = [Item]()
    var notes: [Note] = [Note]()
    
    var list : Array<String> {
        get {
            getListContent()
        }
        set {
            setListContent(newValue)
        }
    }
    
    public init() {
        getUser { user, error in
            self.user = user
        }
        getProfile { profile, error in
            self.profile = profile
        }
        getAllNotes { notes, error in
            self.notes = notes
        }
        getAllItems { items, error in
            self.items = items
        }
    }
    
}
