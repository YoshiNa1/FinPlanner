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
//    func loadList() {
//        return syncManager.loadList()
//    }
    
    func listItem(at index: Int) -> String {
        return syncManager.listItem(at: index)
    }
    func append(listItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.doListAction(.appendItemAction, item: listItem, completion: completion)
    }
    func replaceListItem(from srcIndex: Int, to destIndex: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.doListAction(.replaceItemAction, idx: srcIndex, destIdx: destIndex, completion: completion)
    }
    func insert(listItem: String, at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.doListAction(.insertItemAction, idx: index, item: listItem, completion: completion)
    }
    func deleteListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.doListAction(.deleteItemAction, idx: index, completion: completion)
    }
    func markListItem(at index: Int, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.doListAction(.markItemAction, idx: index, completion: completion)
    }
    func updateListItem(at index: Int, withNewListItem newListItem: String, completion: @escaping (Array<String>, Error?) -> Void) {
        syncManager.doListAction(.updateItemAction, idx: index, item: newListItem, completion: completion)
    }
}
