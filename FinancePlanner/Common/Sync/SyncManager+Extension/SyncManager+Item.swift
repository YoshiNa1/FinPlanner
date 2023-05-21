//
//  SyncManager+Item.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension SyncManager {
    func doItemAction(_ action: SyncAction, item: Item, newItem: Item? = nil, completion: @escaping (Item?, Error?) -> Void) {
        let task = SyncTaskCache(item: item, newItem: newItem, actionType: action.rawValue)
        SyncTaskManager.instance.addTaskInQuery(task: task)
        
        let requestCompletion: (NEItem?, Error?) -> Void = { item, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let item = item {
                SyncTaskManager.instance.removeTaskFromQuery(task: task)
                
                let complItem = Item(neItem: item)
                self.cache(item: complItem, action: action)
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
                if cachedItem.isActive {
                    let item = Item(cache: cachedItem)
                    complItems.append(item)
                }
            })
            completion(complItems, nil)
        }
    }
    
    private func cache(item: Item, newItem: Item? = nil, action: SyncAction) {
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
    
    private func add(item: ItemCache) {
        try! self.realm.write({
            self.realm.add(item, update: .all)
        })
    }
    private func delete(item: ItemCache) {
        try! self.realm.write({
            if let itemCache = realm.object(ofType: ItemCache.self, forPrimaryKey: item.uuid) {
                itemCache.isActive = false
//                self.realm.delete(item)
            }
        })
    }
    private func update(item: ItemCache, withNewItem newItem: ItemCache) {
        try! self.realm.write({
            if let itemCache = realm.object(ofType: ItemCache.self, forPrimaryKey: item.uuid) {
                itemCache.name = newItem.name
                itemCache.descrpt = newItem.descrpt
                itemCache.amount = newItem.amount
                itemCache.currency = newItem.currency
                itemCache.category = newItem.category
                
           }
        })
        /* Прикол в том, что из-за свойства newItem в SyncTaskCache
         в оффлайне при апдейте происходит 'дубликат' записей
         (кэш объектов ItemCache содержит объект из SyncTaskCache) */
        self.delete(item: newItem) // TODO: HARDCODE. CHANGE OFFLINE UPDATE LOGIC
    }
}