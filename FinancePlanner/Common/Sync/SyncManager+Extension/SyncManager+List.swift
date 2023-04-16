//
//  SyncManager+List.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

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
    
    func setListContent(_ content: Array<String>, completion: @escaping (Array<String>, Error?) -> Void) {
        if Connectivity.isConnected() {
            ListRequests().update(content: content) { list, error in
                var listContent = Array<String>()
                if let list = list {
                    listContent = list.content
                }
                completion(listContent, error)
            }
        } else {
            try! self.realm.write {
                if let cachedList = self.realm.objects(ListCache.self).first {
                    self.realm.delete(cachedList)
                    
                    let newList = ListCache(content: content)
                    self.realm.add(newList)
                }
                completion(content, nil)
            }
        }
    }
    
    func getUserList(completion: @escaping (FPList?, Error?) -> Void) {
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
    
    
    func listItem(at index: Int) -> String {
        return list[index]
    }
    
    func append(listItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        list.append(listItem)
        self.setListContent(self.list, completion: completion)
    }
    func insert(listItem: String, at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        list.insert(listItem, at: index)
        self.setListContent(self.list, completion: completion)
    }
    func replaceListItem(from srcIndex: Int, to destIndex: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        let listItem = list[srcIndex]
        list.remove(at: srcIndex)
        list.insert(listItem, at: destIndex)
        self.setListContent(self.list, completion: completion)
    }
    func deleteListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        list.remove(at: index)
        self.setListContent(self.list, completion: completion)
    }
    func updateListItem(at index: Int, withNewListItem newListItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        list[index] = newListItem
        self.setListContent(self.list, completion: completion)
    }
    func markListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
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
