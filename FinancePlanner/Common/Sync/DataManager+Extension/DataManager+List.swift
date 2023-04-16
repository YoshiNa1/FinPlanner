//
//  DataManager+List.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension DataManager {
    var listCount: Int {
        return syncManager.list.count
    }
    
    func listItem(at index: Int) -> String {
        return syncManager.listItem(at: index)
    }
    func append(listItem: String) {
        return syncManager.append(listItem: listItem)
    }
    func insert(listItem: String, at index: Int) {
        return syncManager.insert(listItem: listItem, at: index)
    }
    func deleteListItem(at index: Int) {
        return syncManager.deleteListItem(at: index)
    }
    func updateListItem(at index: Int, withNewListItem newListItem: String) {
        syncManager.list[index] = newListItem
    }
}
