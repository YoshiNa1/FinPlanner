//
//  SyncManager+List.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension SyncManager {

    func getListContent() -> Array<String> {
        if let list = getUserList()?.content {
            return Array(list)
        }
        return Array<String>()
    }
    
    func setListContent(_ content: Array<String>) {
        if let list = getUserList() {
            if Connectivity.isConnected() {
                ListRequests().update(content: content) { _, _ in }
            } else {
                try! self.realm.write {
                    let cachedList = ListCache(list)
                    self.realm.delete(cachedList)
                    
                    let newList = ListCache(content: content)
                    self.realm.add(newList)
                }
            }
        }
    }
    
    func getUserList() -> FPList? {
        var complList: FPList?
        if Connectivity.isConnected() {
            ListRequests().get { neList, error in
                if let neList = neList {
                    complList = FPList(neList:neList)
                }
            }
        } else {
            if let cachedList = self.realm.objects(ListCache.self).first {
                complList = FPList(cache:cachedList)
            }
        }
        return complList
    }
    
    
    func listItem(at index: Int) -> String {
        return list[index]
    }
    func append(listItem: String) {
        list.append(listItem)
    }
    func insert(listItem: String, at index: Int) {
        list.insert(listItem, at: index)
    }
    func deleteListItem(at index: Int) {
        list.remove(at: index)
    }
    func updateListItem(at index: Int, withNewListItem newListItem: String) {
        list[index] = newListItem
    }
        
}
