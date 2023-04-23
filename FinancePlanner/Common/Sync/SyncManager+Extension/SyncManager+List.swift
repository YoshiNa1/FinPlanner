//
//  SyncManager+List.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

enum SyncListAction: Int {
    case appendItemAction
    case insertItemAction
    case replaceItemAction
    case deleteItemAction
    case updateItemAction
    case markItemAction
}

extension SyncManager {
    func loadList() {
        self.getUserList() { list, error in
            var listContent = Array<String>()
            if let list = list {
                listContent = list.content
            }
            self.list = listContent
        }
    }
    
    func doListAction(_ action: SyncListAction, idx: Int = 0, item: String = "", destIdx: Int = 0, completion: @escaping (Array<String>, Error?) -> Void) {
        let task = SyncTaskCache(idx: idx, listItem: item, destIdx: destIdx, actionType: action.rawValue)
        SyncTaskManager.instance.addTaskInQuery(task: task)
        
        let requestCompletion: (Array<String>, Error?) -> Void = { listContent, error in
            if let error = error {
                completion([], error)
                return
            }
            SyncTaskManager.instance.removeTaskFromQuery(task: task)
            self.cacheListContent(listContent) { _, _ in }
            completion(listContent, error)
        }
        switch action {
        case .appendItemAction:
            self.append(listItem: item, completion: requestCompletion)
        case .insertItemAction:
            self.insert(listItem: item, at: idx, completion: requestCompletion)
        case .replaceItemAction:
            self.replaceListItem(from: idx, to: destIdx, completion: requestCompletion)
        case .deleteItemAction:
            self.deleteListItem(at: idx, completion: requestCompletion)
        case .updateItemAction:
            self.updateListItem(at: idx, withNewListItem: item, completion: requestCompletion)
        case .markItemAction:
            self.markListItem(at: idx, completion: requestCompletion)
        }
    }
    
    private func getUserList(completion: @escaping (FPList?, Error?) -> Void) {
        var complList: FPList?
        if Connectivity.isConnected() {
            ListRequests().get { neList, error in
                if let neList = neList {
                    complList = FPList(neList:neList)
                }
                completion(complList, error)
            }
        } else {
            if let cachedList = self.realm.objects(ListCache.self).first {
                complList = FPList(cache:cachedList)
            }
            completion(complList, nil)
        }
    }
    
    private func setListContent(_ content: Array<String>, completion: @escaping (Array<String>, Error?) -> Void) {
        if Connectivity.isConnected() {
            ListRequests().update(content: content) { list, error in
                var listContent = Array<String>()
                if let list = list {
                    listContent = list.content
                }
                completion(listContent, error)
            }
        } else {
            self.cacheListContent(content, completion: completion)
        }
    }
    
    private func cacheListContent(_ content: Array<String>, completion: @escaping (Array<String>, Error?) -> Void) {
        try! self.realm.write {
            if let cachedList = self.realm.objects(ListCache.self).first {
                self.realm.delete(cachedList)
                
                let newList = ListCache(content: content)
                self.realm.add(newList)
            }
            completion(content, nil)
        }
    }
    
    func listItem(at index: Int) -> String {
        return list[index]
    }
    
    private func append(listItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        list.append(listItem)
        self.setListContent(self.list, completion: completion)
    }
    private func insert(listItem: String, at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        list.insert(listItem, at: index)
        self.setListContent(self.list, completion: completion)
    }
    private func replaceListItem(from srcIndex: Int, to destIndex: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        let listItem = list[srcIndex]
        list.remove(at: srcIndex)
        list.insert(listItem, at: destIndex)
        self.setListContent(self.list, completion: completion)
    }
    private func deleteListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        list.remove(at: index)
        self.setListContent(self.list, completion: completion)
    }
    private func updateListItem(at index: Int, withNewListItem newListItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        list[index] = newListItem
        self.setListContent(self.list, completion: completion)
    }
    private func markListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        let item = list[index]
        var newItem = item
        
        if item.contains("<done>") {
            newItem = item.replacingOccurrences(of:"<done>", with:"")
        } else {
            newItem = item + "<done>"
        }
        list.remove(at: index)
        list.insert(newItem, at: index)
        self.setListContent(self.list, completion: completion)
    }
}
