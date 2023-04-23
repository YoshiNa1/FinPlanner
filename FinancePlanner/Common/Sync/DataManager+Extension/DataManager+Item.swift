//
//  DataManager+Item.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension DataManager {
    func getAllItems(completion: @escaping ([Item], Error?) -> Void) {
        syncManager.getAllItems(completion: completion)
    }
    
//    func getItemBy(uuid: String, completion: @escaping (Item?, Error?) -> Void) {
//        syncManager.getItemBy(uuid: uuid, completion: completion)
//    }
    
    func add(item: Item, completion: @escaping (Item?, Error?) -> Void) {
        syncManager.doItemAction(.createAction, item: item, completion: completion)
    }
    
    func delete(item: Item, completion: @escaping (Item?, Error?) -> Void) {
        syncManager.doItemAction(.deleteAction, item: item, completion: completion)
    }
    
    func update(item: Item, withNewItem newItem: Item, completion: @escaping (Item?, Error?) -> Void) {
        syncManager.doItemAction(.editAction, item: item, newItem: newItem, completion: completion)
    }
    
    func getItemsBy(date: Date, completion: @escaping ([Item], Error?) -> Void) { // FOR FREQUENCY TYPE DAY
        var complItems = [Item]()
        self.getAllItems { items, error in
            items.forEach { (item) in
                if CalendarHelper().isDate(date: item.created, equalTo: date) {
                    complItems.append(item)
                }
            }
            completion(complItems, error)
        }
    }
    
    func getMonthItemsBy(date: Date, completion: @escaping ([[Int:[Item]]], Error?) -> Void) {  // FOR FREQUENCY TYPE MONTH
        /* возвращать массив словарей. В нём столько элементов, сколько всего дней в месяце. Каждый элемент
        массива хранит словарь, где ключ -- номер дня. Каждый день хранит массив айтемов с этим днём в этом месяце. */
        
        var complItems = [[Int:[Item]]]()
        
        var monthItems = [Item]()
        let (_, month, year) = CalendarHelper().componentsByDate(date)
        self.getAllItems { items, error in
            items.forEach { (item) in
                let (_, item_month, item_year) = CalendarHelper().componentsByDate(item.created)
                if (item_month == month && item_year == year) {
                    monthItems.append(item)
                }
            }
            
            for day in CalendarHelper().days(for: date) {
                var sortedItems = [Int:[Item]]()
                
                let itemsInDay = monthItems.filter { (item) in
                    let (item_day, _, _) = CalendarHelper().componentsByDate(item.created)
                    return item_day == day
                }
                sortedItems[day] = itemsInDay
                
                complItems.append(sortedItems)
            }
            
            completion(complItems, error)
        }
    }
    
    func getYearItemsBy(date: Date, completion: @escaping ([[ItemCategoryType:[Item]]], Error?) -> Void) {  // FOR FREQUENCY TYPE YEAR
        
        /* должен быть на выходе массив словарей. В нём 12 элементов -- сколько всего месяцев. Каждый элемент
        массива хранит словарь, где ключ -- категория. В словаре столько ключей, сколько всего категорий.
        Значение каждой категории -- массив айтемов с этой категорией в этом месяце. */
        
        var complItems = [[ItemCategoryType:[Item]]]()
        
        var yearItems = [Item]()
        let (_, _, year) = CalendarHelper().componentsByDate(date)
        
        self.getAllItems { items, error in
            items.forEach { (item) in
                let (_, _, item_year) = CalendarHelper().componentsByDate(item.created)
                if item_year == year {
                    yearItems.append(item)
                }
            }
            
            for month in 1...12 {
                var categorisedItems = [ItemCategoryType:[Item]]()
                
                //FIRSTLY, FILTER ALL ITEMS IN YEAR BY CURRENT MONTH
                let itemsInMonth = yearItems.filter( { (item) in
                    let (_, item_month, _) = CalendarHelper().componentsByDate(item.created)
                    return item_month == month
                })
                
                for category in ItemCategoryType.all {
                    //SECONDLY, GET ITEMS IN CURRENT MONTH, FILTERED BY CURRENT CATEGORY
                    let monthItemsByCategory = itemsInMonth.filter { (item) in
                        return item.categoryType == category
                    }
                    //SET FILTERED ITEMS IN DICTIONARY FOR KEY CURRENT CATEGORY
                    categorisedItems[category] = monthItemsByCategory
                }
                //APPEND DICTIONARY OF CATEGORIES(KEYS) AND ITEMS(VALUES) FOR CURRENT MONTH
                complItems.append(categorisedItems)
            }
            
            completion(complItems, error)
        }
    }
    
    
    func getStatisticsItemsBy(date: Date, frequencyType: StatisticsFrequency, type: ItemType = .none, completion: @escaping ([String:[Item]], Error?) -> Void) {
        var complItems = [String:[Item]]()
        
        var allItems = [Item]()
        let (_, month, year) = CalendarHelper().componentsByDate(date)
        
        self.getAllItems { items, error in
            switch frequencyType {
            case .day:
                var dayItems = [Item]()
                items.forEach { (item) in
                    if CalendarHelper().isDate(date: item.created, equalTo: date) {
                        dayItems.append(item)
                    }
                }
                allItems = dayItems
            case .month:
                var monthItems = [Item]()
                items.forEach { (item) in
                    let (_, item_month, item_year) = CalendarHelper().componentsByDate(item.created)
                    if (item_month == month && item_year == year) {
                        monthItems.append(item)
                    }
                }
                allItems = monthItems
            case .year:
                var yearItems = [Item]()
                items.forEach { (item) in
                    let (_, _, item_year) = CalendarHelper().componentsByDate(item.created)
                    if item_year == year {
                        yearItems.append(item)
                    }
                }
                allItems = yearItems
            }
            
            if type != .none {
                /* на выходе массив словарей. В нём столько элементов, сколько всего категорий.
                 Каждая категория содержит массив элементов */
                for category in ItemCategoryType.all {
                    complItems[category.rawValue] = allItems.filter{ $0.categoryType == category && $0.itemType == type}
                }
            } else {
                /* на выходе два элемента в словаре. 1. key: expenses, value: [Item]; 2. key: incomes, value: [Item]. */
                complItems[ItemType.outcome.rawValue] = allItems.filter{ $0.itemType == .outcome }
                complItems[ItemType.income.rawValue] = allItems.filter{ $0.itemType == .income }
            }
            
            completion(complItems, error)
        }
    }
    
    func createYearItem(with items: [Item]) -> Item {
        var amount = 0.0
        items.forEach { (item) in
            let itemAmount = item.amount
            let itemCurrency = item.currency
            let defAmount = getDefaultAmount(amount: itemAmount, currency: itemCurrency)
            amount += defAmount
        }
        return Item(amount: amount,
                    category: items.first?.categoryType ?? .none,
                    date: items.first?.created ?? Date())
    }
    
}
