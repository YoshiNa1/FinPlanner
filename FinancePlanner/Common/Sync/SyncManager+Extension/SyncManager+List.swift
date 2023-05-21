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
    
    func listItem(at index: Int) -> String {
        return list[index]
    }
    
    func loadList() {
        self.list.removeAll()
        if let cachedList = self.realm.objects(ListCache.self).first {
            cachedList.content.forEach { listItem in
                self.list.append(listItem)
            }
        }
    }
    
    func doListAction(_ action: SyncListAction, idx: Int = 0, item: String = "", destIdx: Int = 0, completion: @escaping (Array<String>, Error?) -> Void) {
        if !Connectivity.isConnected() {
            loadList()
        }
        switch action {
        case .appendItemAction:
            self.append(listItem: item)
        case .insertItemAction:
            self.insert(listItem: item, at: idx)
        case .replaceItemAction:
            self.replaceListItem(from: idx, to: destIdx)
        case .deleteItemAction:
            self.deleteListItem(at: idx)
        case .updateItemAction:
            self.updateListItem(at: idx, withNewListItem: item)
        case .markItemAction:
            self.markListItem(at: idx)
        }
        
        self.cacheListContent(self.list)
        
        if Connectivity.isConnected() {
            ListRequests().update(content: self.list) { list, error in
                if let error = error {
                    completion([], error)
                    return
                }
                var listContent = Array<String>()
                if let list = list {
                    listContent = list.content
                }
                completion(listContent, error)
            }
        } else {
            completion(self.list, nil)
        }
    }
    
    private func cacheListContent(_ content: Array<String>) {
        try! self.realm.write {
            if let cachedList = self.realm.objects(ListCache.self).first {
                self.realm.delete(cachedList)
                
                let newList = ListCache(content: content)
                self.realm.add(newList)
            }
        }
    }
    
    private func append(listItem: String) {
        list.append(listItem)
    }
    private func insert(listItem: String, at index: Int) {
        list.insert(listItem, at: index)
    }
    private func replaceListItem(from srcIndex: Int, to destIndex: Int) {
        if !list.isEmpty {
            let listItem = list[srcIndex]
            list.remove(at: srcIndex)
            list.insert(listItem, at: destIndex)
        }
    }
    private func deleteListItem(at index: Int) {
        if !list.isEmpty {
            list.remove(at: index)
        }
    }
    private func updateListItem(at index: Int, withNewListItem newListItem: String) {
        if !list.isEmpty {
            list[index] = newListItem
        }
    }
    private func markListItem(at index: Int) {
        if !list.isEmpty {
            let item = list[index]
            var newItem = item
            
            if item.contains("<done>") {
                newItem = item.replacingOccurrences(of:"<done>", with:"")
            } else {
                newItem = item + "<done>"
            }
            list.remove(at: index)
            list.insert(newItem, at: index)
        }
    }
}
