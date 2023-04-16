//
//  DataManager+List.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension DataManager {
    func getList() -> Array<String> {
        return syncManager.list
    }
    func loadList() {
        return syncManager.loadList()
    }
    
    func listItem(at index: Int) -> String {
        return syncManager.listItem(at: index)
    }
    func append(listItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.append(listItem: listItem, completion: completion)
    }
    func replaceListItem(from srcIndex: Int, to destIndex: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.replaceListItem(from: srcIndex, to: destIndex, completion: completion)
    }
    func insert(listItem: String, at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.insert(listItem: listItem, at: index, completion: completion)
    }
    func deleteListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.deleteListItem(at: index, completion: completion)
    }
    func markListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.markListItem(at: index, completion: completion)
    }
    func updateListItem(at index: Int, withNewListItem newListItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.updateListItem(at: index, withNewListItem: newListItem, completion: completion)
    }
}
