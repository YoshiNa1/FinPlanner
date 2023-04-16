//
//  SyncManager+Item.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension SyncManager {
    func doItemAction(_ action: SyncAction, item: Item, newItem: Item? = nil, completion: @escaping (Item?, Error?) -> Void) {
        let requestCompletion: (NEItem?, Error?) -> Void = { item, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let item = item {
                let complItem = Item(neItem: item)
                
                completion(complItem, error)
            }
        }
        if Connectivity.isConnected() {
            let request = ItemRequests()
            let item = NEItem(item)
            switch action {
            case .getAction:
                request.get(uuid: item.uuid, completion: requestCompletion)
            case .createAction:
                request.create(item: item, completion: requestCompletion)
            case .editAction:
                if let newItem = newItem {
                    let neNewItem = NEItem(newItem)
                    request.update(uuid: item.uuid, item: neNewItem, completion: requestCompletion)
                }
            case .deleteAction:
                request.delete(uuid: item.uuid, completion: requestCompletion)
            }
        } else {
            self.cache(item: item, newItem: newItem, action: action)
            completion(item, nil)
        }
        
    }
    
    func cache(item: Item, newItem: Item? = nil, action: SyncAction) {
        let itemCache = ItemCache(item)
        switch action {
        case .createAction:
            self.add(item: itemCache)
        case .editAction:
            if let newItem = newItem {
                let newItemCache = ItemCache(newItem)
                self.update(item: itemCache, withNewItem: newItemCache)
            }
        case .deleteAction:
            self.delete(item: itemCache)
        default: break
        }
    }
    
    
    func getAllItems(completion: @escaping ([Item], Error?) -> Void) {
        var complItems = [Item]()
        if Connectivity.isConnected() {
            ItemRequests().getAll { items, error in
                items?.forEach({ neItem in
                    let item = Item(neItem: neItem)
                    complItems.append(item)
                })
                completion(complItems, error)
            }
        } else {
            let items = self.realm.objects(ItemCache.self)
            items.forEach({ cachedItem in
                let item = Item(cache: cachedItem)
                complItems.append(item)
            })
            completion(complItems, nil)
        }
    }
    
    
    func getItemBy(uuid: String, completion: @escaping (Item?) -> Void) {
        if Connectivity.isConnected() {
            ItemRequests().get(uuid: uuid) { item, error in
                if let neItem = item {
                    let item = Item(neItem: neItem)
                    completion(item)
                }
            }
        } else {
            if let item = items.first(where: {$0.uuid == uuid}) {
                completion(item)
            }
        }
    }
    
    func add(item: ItemCache) {
        try! self.realm.write({
            realm.add(item, update: .all)
        })
    }
    func delete(item: ItemCache) {
        try! self.realm.write({
            realm.delete(item)
        })
    }
    func update(item: ItemCache, withNewItem newItem: ItemCache) {
        try! self.realm.write({
            item.name = newItem.name
            item.descrpt = newItem.descrpt
            item.amount = newItem.amount
            item.currency = newItem.currency
            item.category = newItem.category
        })
    }
        
}
