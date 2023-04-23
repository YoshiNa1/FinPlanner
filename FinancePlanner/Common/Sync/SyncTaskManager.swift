//
//  SyncTaskManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 22.04.2023.
//

import Foundation
import RealmSwift

public class SyncTaskManager {
    private var tasks: [SyncTaskCache] {
        get {
            var tasks: [SyncTaskCache] = [SyncTaskCache]()
            let tasksCache: Results<SyncTaskCache> = syncManager.realm.objects(SyncTaskCache.self)
            for taskCache in tasksCache {
                tasks.append(taskCache)
            }
            return tasks
        }
    }
    
    public static var instance: SyncTaskManager = {
        let instance = SyncTaskManager()
        return instance
    }()
    
    private(set) var syncManager: SyncManager
    private init() {
        syncManager = SyncManager()
    }
    
    func addTaskInQuery(task: SyncTaskCache) {
        try? syncManager.realm.write({
            syncManager.realm.add(task, update: .all)
        })
    }
    
    func removeTaskFromQuery(task: SyncTaskCache) {
        if let syncTaskCache = syncManager.realm.object(ofType: SyncTaskCache.self, forPrimaryKey: task.uuid) {
            try? syncManager.realm.write ({
                self.clearAll(in: syncTaskCache)
                syncManager.realm.delete(syncTaskCache)
            })
        }
    }
    
    func doTasksFromQuery(completion: @escaping () -> Void) {
        if !tasks.isEmpty {
            let group = DispatchGroup()
            
            for task in tasks {
                if task.isListTask {
                    guard let syncListAction = SyncListAction(rawValue: task.actionType) else { completion(); return}
                    let listItem = task.listItem ?? ""
                    let listIndex = task.listIdx ?? 0
                    let listDestIdx =  task.listDestIdx ?? 0
                    group.enter()
                    syncManager.doListAction(syncListAction, idx: listIndex, item: listItem, destIdx: listDestIdx) { listContent, error in
                        group.leave()
                    }
                } else {
                    guard let syncAction = SyncAction(rawValue: task.actionType) else { completion(); return}
                    if let itemCache = task.item {
                        let item = Item(cache: itemCache)
                        var newItem: Item?
                        if let updatedItem = task.updItem {
                            newItem = Item(cache: updatedItem)
                        }
                        group.enter()
                        syncManager.doItemAction(syncAction, item: item, newItem: newItem) { item, error in
                            group.leave()
                        }
                    }
                    
                    if let noteCache = task.note {
                        let note = Note(cache: noteCache)
                        var newNote: Note?
                        if let updatedNote = task.updNote {
                            newNote = Note(cache: updatedNote)
                        }
                        group.enter()
                        syncManager.doNoteAction(syncAction, note: note, newNote: newNote) { note, error in
                            group.leave()
                        }
                    }
                    
                    if let profileCache = task.profile {
                        let profile = Profile(cache: profileCache)
                        group.enter()
                        syncManager.doProfileAction(syncAction, profile: profile) { profile, error in
                            group.leave()
                        }
                    }
                }
            }

            group.notify(queue: DispatchQueue.main) {
                completion()
            }
        }
        else {
            completion()
        }
    }
    
    
    private func clearAll(in task: SyncTaskCache) {
        if let task = syncManager.realm.object(ofType: SyncTaskCache.self, forPrimaryKey: task.uuid) {
            if let item = task.item,
               let itemCache = syncManager.realm.object(ofType: ItemCache.self, forPrimaryKey: item.uuid) {
                syncManager.realm.delete(itemCache)
            }
            if let updItem = task.updItem,
               let updItemCache = syncManager.realm.object(ofType: ItemCache.self, forPrimaryKey: updItem.uuid) {
                syncManager.realm.delete(updItemCache)
            }
            if let note = task.note,
               let noteCache = syncManager.realm.object(ofType: NoteCache.self, forPrimaryKey: note.uuid) {
                syncManager.realm.delete(noteCache)
            }
            if let updNote = task.updNote,
               let updNoteCache = syncManager.realm.object(ofType: NoteCache.self, forPrimaryKey: updNote.uuid) {
                syncManager.realm.delete(updNoteCache)
            }
            if let profile = task.profile,
               let profileCache = syncManager.realm.object(ofType: ProfileCache.self, forPrimaryKey: profile.uuid) {
                syncManager.realm.delete(profileCache)
            }
        }
    }
    
}
