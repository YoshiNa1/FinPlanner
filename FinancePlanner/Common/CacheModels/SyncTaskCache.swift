//
//  SyncTaskCache.swift
//  FinancePlanner
//
//  Created by Anastasiia on 22.04.2023.
//

import Foundation
import RealmSwift

public class SyncTaskCache: Object {
    @objc dynamic var uuid: String = UUID().uuidString.lowercased()
    
    @objc dynamic var profile: ProfileCache?
    
//    @objc dynamic var list: ListCache? = ListCache()
    @objc dynamic var isListTask: Bool = false
    @objc dynamic var listItem: String? = ""
    dynamic var listIdx: Int? = 0
    dynamic var listDestIdx: Int? = 0
    
    @objc dynamic var item: ItemCache?
    @objc dynamic var updItem: ItemCache?
    
    @objc dynamic var note: NoteCache?
    @objc dynamic var updNote: NoteCache?
    
    @objc dynamic var actionType: Int = -1
    
    override required init() {
        super.init()
    }
    
    public override static func primaryKey() -> String? {
        return "uuid"
    }
    
    public init(profile: Profile,
                actionType: Int) {
        self.profile = ProfileCache(profile)
        self.actionType = actionType
    }
    
    public init(idx: Int?,
                listItem: String?,
                destIdx: Int?,
                actionType: Int) {
        self.listItem = listItem
        self.listIdx = idx
        self.listDestIdx = destIdx
        self.actionType = actionType
        self.isListTask = true
    }
    
    public init(item: Item,
                newItem: Item?,
                actionType: Int) {
        self.item = ItemCache(item)
        if let newItem = newItem {
            self.updItem = ItemCache(newItem)
        }
        self.actionType = actionType
    }
    
    public init(note: Note,
                newNote: Note?,
                actionType: Int) {
        self.note = NoteCache(note)
        if let newNote = newNote {
            self.updNote = NoteCache(newNote)
        }
        self.actionType = actionType
    }
    
}
