//
//  DataManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import Foundation
import RealmSwift

class DataManager {
    let realm = try! Realm()
    
    var defaultCurrency: String {
        get { PreferencesStorage.shared.defaultCurrency?.name ?? ""}
    }
    
    var user: UserCache!
    var profile: ProfileCache!
    var items : Results<ItemCache>!
    var notes : Results<NoteCache>!
    var list : Array<String> {
        get {
            getListContent()
        }
        set {
            setListContent(newValue)
        }
    }
    
    public static var instance: DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private init() {
        user = self.realm.objects(UserCache.self).first
        profile = getProfileByUUID(user.uuid)
        items = getAllItems(user.uuid)
        notes = getAllNotes(user.uuid)
    }
    
// MARK: - Profile
    
    private func getProfileByUUID(_ uuid: String) -> ProfileCache? {
        guard let profile = self.realm.objects(ProfileCache.self).first(where: {$0.userUuid == uuid}) else { return nil }
        return profile
    }
    
    private func create(profile: ProfileCache) {
        try! self.realm.write({
            realm.add(profile, update: .all)
        })
        self.profile = self.realm.objects(ProfileCache.self).first
    }
    
    func createProfile(with balance: Double, _ balanceCurrency: String, and savings: Double, _ savingsCurrency: String) {
        let defBalanceAmount = self.getDefaultAmount(amount: balance, currency: balanceCurrency)
        let defSavingsAmount = self.getDefaultAmount(amount: savings, currency: savingsCurrency)
        let profile = ProfileCache(userUuid: user.uuid, balance: defBalanceAmount, savings: defSavingsAmount, currency: self.defaultCurrency)
        self.create(profile: profile)
    }
    
    func updateProfile(withAmount amount: Double, currency: String, isBalance: Bool) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        try! self.realm.write({
            if(isBalance) {
                self.profile.balance = defAmount
            } else {
                self.profile.savings = defAmount
            }
        })
    }
    
    func updateProfile(withTransactionAmount amount: Double, currency: String, isWithdraw: Bool) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        try! self.realm.write({
            if(isWithdraw) {
                self.profile.savings -= defAmount
                self.profile.balance += defAmount
            } else {
                self.profile.savings += defAmount
                self.profile.balance -= defAmount
            }
        })
    }
   
    func updateProfile(withItem item: ItemCache, amount: Double, isRemoval: Bool = false) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: item.currency)
        try! self.realm.write({
            if(isRemoval) {
                if(item.itemType == .outcome) {
                    self.profile.balance += defAmount
                }
                if(item.itemType == .income) {
                    self.profile.balance -= defAmount
                }
            } else {
                if(item.itemType == .outcome) {
                    self.profile.balance -= defAmount
                }
                if(item.itemType == .income) {
                    self.profile.balance += defAmount
                }
            }
        })
    }
    
    func updateProfile(withCurrency newDefaultCurrency: String) {
        if let profile = self.profile {
            let oldDefaultCurrency = profile.currency
            let defBalanceAmount = self.getDefaultAmount(amount: profile.balance, currency: oldDefaultCurrency)
            let defSavingsAmount = self.getDefaultAmount(amount: profile.savings, currency: oldDefaultCurrency)
            try! self.realm.write({
                self.profile.currency = newDefaultCurrency
                self.profile.balance = defBalanceAmount
                self.profile.savings = defSavingsAmount
            })
        }
    }
    
    func removeProfile() {
        try! self.realm.write({
            realm.delete(profile)
            profile = nil
        })
    }
    
// MARK: - Item
    private func getAllItems(_ uuid: String) -> Results<ItemCache> {
        let items = self.realm.objects(ItemCache.self).where({$0.userUuid == uuid})
        return items
    }
    
    func getItemsBy(date: Date) -> [ItemCache] { // FOR FREQUENCY TYPE DAY
        var items = [ItemCache]()
        self.items.forEach { (item) in
            if CalendarHelper().isDate(date: item.date, equalTo: date) {
                items.append(item)
            }
        }
        return items
    }
    
    func getMonthItemsBy(date: Date) -> [[Int:[ItemCache]]] {  // FOR FREQUENCY TYPE MONTH
        
        /* возвращать массив словарей. В нём столько элементов, сколько всего дней в месяце. Каждый элемент
        массива хранит словарь, где ключ -- номер дня. Каждый день хранит массив айтемов с этим днём в этом месяце. */
        
        var items = [[Int:[ItemCache]]]()
        
        var monthItems = [ItemCache]()
        let (_, month, year) = CalendarHelper().componentsByDate(date)
        self.items.forEach { (item) in
            let (_, item_month, item_year) = CalendarHelper().componentsByDate(item.date)
            if (item_month == month && item_year == year) {
                monthItems.append(item)
            }
        }
        
        for day in CalendarHelper().days(for: date) {
            var sortedItems = [Int:[ItemCache]]()
            
            let itemsInDay = monthItems.filter { (item) in
                let (item_day, _, _) = CalendarHelper().componentsByDate(item.date)
                return item_day == day
            }
            sortedItems[day] = itemsInDay
            
            items.append(sortedItems)
        }
        
        return items
    }
    
    func getYearItemsBy(date: Date) -> [[ItemCategoryType:[ItemCache]]] {  // FOR FREQUENCY TYPE YEAR
        
        /* должен быть на выходе массив словарей. В нём 12 элементов -- сколько всего месяцев. Каждый элемент
        массива хранит словарь, где ключ -- категория. В словаре столько ключей, сколько всего категорий.
        Значение каждой категории -- массив айтемов с этой категорией в этом месяце. */
        
        var items = [[ItemCategoryType:[ItemCache]]]()
        
        var yearItems = [ItemCache]()
        let (_, _, year) = CalendarHelper().componentsByDate(date)
        
        self.items.forEach { (item) in
            let (_, _, item_year) = CalendarHelper().componentsByDate(item.date)
            if item_year == year {
                yearItems.append(item)
            }
        }
        
        
        for month in 1...12 {
            var categorisedItems = [ItemCategoryType:[ItemCache]]()
            
            //FIRSTLY, FILTER ALL ITEMS IN YEAR BY CURRENT MONTH
            let itemsInMonth = yearItems.filter( { (item) in
                let (_, item_month, _) = CalendarHelper().componentsByDate(item.date)
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
            items.append(categorisedItems)
        }
        
        return items
    }
    
    func getStatisticsItemsBy(date: Date, frequencyType: StatisticsFrequency, type: ItemType = .none) -> [String:[ItemCache]] {
        var items = [String:[ItemCache]]()
        
        var allItems = [ItemCache]()
        let (_, month, year) = CalendarHelper().componentsByDate(date)
        
        switch frequencyType {
        case .day:
            var dayItems = [ItemCache]()
            self.items.forEach { (item) in
                if CalendarHelper().isDate(date: item.date, equalTo: date) {
                    dayItems.append(item)
                }
            }
            allItems = dayItems
        case .month:
            var monthItems = [ItemCache]()
            self.items.forEach { (item) in
                let (_, item_month, item_year) = CalendarHelper().componentsByDate(item.date)
                if (item_month == month && item_year == year) {
                    monthItems.append(item)
                }
            }
            allItems = monthItems
        case .year:
            var yearItems = [ItemCache]()
            self.items.forEach { (item) in
                let (_, _, item_year) = CalendarHelper().componentsByDate(item.date)
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
                items[category.rawValue] = allItems.filter({ (item) in
                    return item.categoryType == category && item.itemType == type
                })
            }
        } else {
            /* на выходе два элемента в словаре. 1. key: expenses, value: [Item]; 2. key: incomes, value: [Item]. */
            items["Expenses"] = allItems.filter({ (item) in
                return item.itemType == .outcome
            })
            items["Incomes"] = allItems.filter({ (item) in
                return item.itemType == .income
            })
        }
        
        return items
    }
    
    func createYearItem(with items: [ItemCache]) -> ItemCache {
        var amount = 0.0
        items.forEach { (item) in
            let itemAmount = item.amount
            let itemCurrency = item.currency
            let defAmount = getDefaultAmount(amount: itemAmount, currency: itemCurrency)
            amount += defAmount
        }
        return ItemCache(userUuid: user.uuid,
                    amount: amount,
                    category: items.first?.categoryType ?? .none,
                    date: items.first?.date ?? Date())
    }
    
//    func createItem(isIncome: Bool,
//                    amount: Double,
//                    date: Date) {
//        let item = Item(userId: user.uuid,
//                        isIncome: isIncome,
//                        amount: amount,
//                        date: date)
//        add(item: item)
//    }

    func createItem(type:ItemType,
                    name: String,
                    description: String,
                    amount: Double,
                    currency: String,
                    category:ItemCategoryType,
                    date: Date) -> ItemCache {
        let item = ItemCache(userUuid: user.uuid,
                        type: type,
                        name: name,
                        description: description,
                        amount: amount,
                        currency: currency,
                        category: category,
                        date: date)
        return item
    }

//    func createItem(amount: Double,
//                    category: ItemCategoryType,
//                    date: Date) {
//        let item = Item(userId: user.uuid,
//                        amount: amount,
//                        category: category,
//                        date: date)
//        add(item: item)
//    }
    
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
    
// MARK: - Note
    func getAllNotes(_ uuid: String) -> Results<NoteCache> {
        let notes = self.realm.objects(NoteCache.self).where({$0.userUuid == uuid})
        return notes
    }
    
    func getNote(by date: Date) -> NoteCache? {
        return notes.first(where: { CalendarHelper().isDate(date: $0.date, equalTo: date) })
    }
    
    func setNote(date: Date, description: String) {
        let note = NoteCache(userUuid: user.uuid, date: date, description: description)
        if let currNote = getNote(by: date) {
            update(note: currNote, withNewNote: note)
        } else {
            add(note: note)
        }
    }
    
    func add(note: NoteCache) {
        try! self.realm.write({
            realm.add(note, update: .all)
        })
    }
    
    func update(note: NoteCache, withNewNote newNote: NoteCache) {
        try! self.realm.write({
            if(newNote.descrpt == "") {
                realm.delete(note)
            } else {
                note.descrpt = newNote.descrpt
            }
        })
    }
    
// MARK: - List
    
    func getUserList(_ uuid: String) -> ListCache? {
        let list = self.realm.objects(ListCache.self).first(where: {$0.userUuid == uuid})
        return list
    }
    
    func getListContent() -> Array<String> {
        if let list = getUserList(user.uuid)?.content {
            return Array(list)
        }
        return Array<String>()
    }
    func setListContent(_ content: Array<String>) {
        try! self.realm.write {
            if let list = getUserList(user.uuid) {
                self.realm.delete(list)
            }
            let newList = ListCache(userUuid: user.uuid, content: content)
            self.realm.add(newList)
        }
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
    
// MARK: - Default Amount
    
    func getDefaultAmount(amount:Double, currency:String) -> Double {
        var _amount: Double = 0
        let amountText = convertAmountToDefault(amount:amount, currency:currency, style: .none)
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        let grade = formatter.number(from: amountText)
        if let doubleGrade = grade?.doubleValue {
            _amount = doubleGrade
        } else {
            _amount = Double(amountText) ?? 0
        }
        return _amount
    }
    
    func convertAmountToDefault(amount:Double, currency:String, style:NumberFormatter.Style = .decimal) -> String {
        let valCurr = ConvCurrency.currency(for: currency)
        let outCurr = ConvCurrency.currency(for: self.defaultCurrency)

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let defAmount = appDelegate.currencyConverter.convertAndFormat(amount, valueCurrency: valCurr, outputCurrency: outCurr, numberStyle: style, decimalPlaces: 2) ?? ""
            return defAmount
        }
        return ""
    }

// MARK: - Validation

    func validatePassword(_ str: String) -> Bool {
        return str.count > 7
    }
}
