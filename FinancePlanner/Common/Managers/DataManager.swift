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
    
    var user: User!
    var account: Account!
    var items : Results<Item>!
    var notes : Results<Note>!
    var list : Array<String> {
        get {
            getListItems()
        }
        set {
            setListItems(newValue)
        }
    }
    
    public static var instance: DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private init() {
        user = self.realm.objects(User.self).first
        account = getAccountByUUID(user.uuid)
        items = getAllItems(user.uuid)
        notes = getAllNotes(user.uuid)
    }
    
// MARK: - Account
    
    private func getAccountByUUID(_ uuid: String) -> Account? {
        guard let account = self.realm.objects(Account.self).first(where: {$0.userId == uuid}) else { return nil }
        return account
    }
    
    private func create(account: Account) {
        try! self.realm.write({
            realm.add(account, update: .all)
        })
        self.account = self.realm.objects(Account.self).first
    }
    
    func createAccount(with balance: Double, _ balanceCurrency: String, and savings: Double, _ savingsCurrency: String) {
        let defBalanceAmount = self.getDefaultAmount(amount: balance, currency: balanceCurrency)
        let defSavingsAmount = self.getDefaultAmount(amount: savings, currency: savingsCurrency)
        let account = Account(uuid: user.uuid, balance: defBalanceAmount, savings: defSavingsAmount, currency: self.defaultCurrency)
        self.create(account: account)
    }
    
    func updateAccount(withAmount amount: Double, currency: String, isBalance: Bool) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        try! self.realm.write({
            if(isBalance) {
                self.account.balance = defAmount
            } else {
                self.account.savings = defAmount
            }
        })
    }
    
    func updateAccount(withTransactionAmount amount: Double, currency: String, isWithdraw: Bool) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        try! self.realm.write({
            if(isWithdraw) {
                self.account.savings -= defAmount
                self.account.balance += defAmount
            } else {
                self.account.savings += defAmount
                self.account.balance -= defAmount
            }
        })
    }
   
    func updateAccount(withItem item: Item, amount: Double, isRemoval: Bool = false) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: item.currency)
        try! self.realm.write({
            if(isRemoval) {
                if(item.itemType == .outcome) {
                    self.account.balance += defAmount
                }
                if(item.itemType == .income) {
                    self.account.balance -= defAmount
                }
            } else {
                if(item.itemType == .outcome) {
                    self.account.balance -= defAmount
                }
                if(item.itemType == .income) {
                    self.account.balance += defAmount
                }
            }
        })
    }
    
    func updateAccount(withCurrency newDefaultCurrency: String) {
        if let account = self.account {
            let oldDefaultCurrency = account.currency
            let defBalanceAmount = self.getDefaultAmount(amount: account.balance, currency: oldDefaultCurrency)
            let defSavingsAmount = self.getDefaultAmount(amount: account.savings, currency: oldDefaultCurrency)
            try! self.realm.write({
                self.account.currency = newDefaultCurrency
                self.account.balance = defBalanceAmount
                self.account.savings = defSavingsAmount
            })
        }
    }
    
    func removeAccount() {
        try! self.realm.write({
            realm.delete(account)
            account = nil
        })
    }
    
// MARK: - Item
    private func getAllItems(_ uuid: String) -> Results<Item> {
        let items = self.realm.objects(Item.self).where({$0.userId == uuid})
        return items
    }
    
    func getItemsBy(date: Date) -> [Item] { // FOR FREQUENCY TYPE DAY
        var items = [Item]()
        self.items.forEach { (item) in
            if CalendarHelper().isDate(date: item.date, equalTo: date) {
                items.append(item)
            }
        }
        return items
    }
    
    func getMonthItemsBy(date: Date) -> [[Int:[Item]]] {  // FOR FREQUENCY TYPE MONTH
        
        /* возвращать массив словарей. В нём столько элементов, сколько всего дней в месяце. Каждый элемент
        массива хранит словарь, где ключ -- номер дня. Каждый день хранит массив айтемов с этим днём в этом месяце. */
        
        var items = [[Int:[Item]]]()
        
        var monthItems = [Item]()
        let (_, month, year) = CalendarHelper().componentsByDate(date)
        self.items.forEach { (item) in
            let (_, item_month, item_year) = CalendarHelper().componentsByDate(item.date)
            if (item_month == month && item_year == year) {
                monthItems.append(item)
            }
        }
        
        for day in CalendarHelper().days(for: date) {
            var sortedItems = [Int:[Item]]()
            
            let itemsInDay = monthItems.filter { (item) in
                let (item_day, _, _) = CalendarHelper().componentsByDate(item.date)
                return item_day == day
            }
            sortedItems[day] = itemsInDay
            
            items.append(sortedItems)
        }
        
        return items
    }
    
    func getYearItemsBy(date: Date) -> [[ItemCategoryType:[Item]]] {  // FOR FREQUENCY TYPE YEAR
        
        /* должен быть на выходе массив словарей. В нём 12 элементов -- сколько всего месяцев. Каждый элемент
        массива хранит словарь, где ключ -- категория. В словаре столько ключей, сколько всего категорий.
        Значение каждой категории -- массив айтемов с этой категорией в этом месяце. */
        
        var items = [[ItemCategoryType:[Item]]]()
        
        var yearItems = [Item]()
        let (_, _, year) = CalendarHelper().componentsByDate(date)
        
        self.items.forEach { (item) in
            let (_, _, item_year) = CalendarHelper().componentsByDate(item.date)
            if item_year == year {
                yearItems.append(item)
            }
        }
        
        
        for month in 1...12 {
            var categorisedItems = [ItemCategoryType:[Item]]()
            
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
    
    func getStatisticsItemsBy(date: Date, frequencyType: StatisticsFrequency, type: ItemType = .none) -> [String:[Item]] {
        var items = [String:[Item]]()
        
        var allItems = [Item]()
        let (_, month, year) = CalendarHelper().componentsByDate(date)
        
        switch frequencyType {
        case .day:
            var dayItems = [Item]()
            self.items.forEach { (item) in
                if CalendarHelper().isDate(date: item.date, equalTo: date) {
                    dayItems.append(item)
                }
            }
            allItems = dayItems
        case .month:
            var monthItems = [Item]()
            self.items.forEach { (item) in
                let (_, item_month, item_year) = CalendarHelper().componentsByDate(item.date)
                if (item_month == month && item_year == year) {
                    monthItems.append(item)
                }
            }
            allItems = monthItems
        case .year:
            var yearItems = [Item]()
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
    
    func createYearItem(with items: [Item]) -> Item {
        var amount = 0.0
        items.forEach { (item) in
            let itemAmount = item.amount
            let itemCurrency = item.currency
            let defAmount = getDefaultAmount(amount: itemAmount, currency: itemCurrency)
            amount += defAmount
        }
        return Item(userId: user.uuid,
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
                    date: Date) -> Item {
        let item = Item(userId: user.uuid,
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
    
    func add(item: Item) {
        try! self.realm.write({
            realm.add(item, update: .all)
        })
    }
    func delete(item: Item) {
        try! self.realm.write({
            realm.delete(item)
        })
    }
    func update(item: Item, withNewItem newItem: Item) {
        try! self.realm.write({
            item.name = newItem.name
            item.descrpt = newItem.descrpt
            item.amount = newItem.amount
            item.currency = newItem.currency
            item.category = newItem.category
        })
    }
    
// MARK: - Note
    func getAllNotes(_ uuid: String) -> Results<Note> {
        let notes = self.realm.objects(Note.self).where({$0.userId == uuid})
        return notes
    }
    
    func getNote(by date: Date) -> Note? {
        return notes.first(where: { CalendarHelper().isDate(date: $0.date, equalTo: date) })
    }
    
    func setNote(date: Date, description: String) {
        let note = Note(userId: user.uuid, date: date, description: description)
        if let currNote = getNote(by: date) {
            update(note: currNote, withNewNote: note)
        } else {
            add(note: note)
        }
    }
    
    func add(note: Note) {
        try! self.realm.write({
            realm.add(note, update: .all)
        })
    }
    
    func update(note: Note, withNewNote newNote: Note) {
        try! self.realm.write({
            if(newNote.descrpt == "") {
                realm.delete(note)
            } else {
                note.descrpt = newNote.descrpt
            }
        })
    }
    
// MARK: - List
    func getUserList(_ uuid: String) -> ListItems? {
        let list = self.realm.objects(ListItems.self).first(where: {$0.userId == uuid})
        return list
    }
    
    func getListItems() -> Array<String> {
        if let list = getUserList(user.uuid)?.items {
            return Array(list)
        }
        return Array<String>()
    }
    func setListItems(_ items: Array<String>) {
        try! self.realm.write {
            if let list = getUserList(user.uuid) {
                self.realm.delete(list)
            }
            let newList = ListItems(userId: user.uuid, items: items)
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
// MARK: - CLASSES
// TODO: - separate files for classes
class User: Object {
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var email: String = ""
    @objc dynamic var password: String = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(email: String,
         password: String) {
        self.email = email
        self.password = password
    }
}

class Account: Object {
    @objc dynamic var userId: String = ""
    @objc dynamic var balance: Double = 0.0
    @objc dynamic var savings: Double = 0.0
    @objc dynamic var currency: String = "" // CHANGE EVERYTIME DEFAULT CURRENCY FROM SETTINGS CHANGED AND UPDATE BALANCE-SAVINGS
    
    override class func primaryKey() -> String? {
        return "userId"
    }
    
    required override init() {
        super.init()
    }
    
    init(uuid: String,
         balance: Double,
         savings: Double,
         currency: String) {
        self.userId = uuid
        self.balance = balance
        self.savings = savings
        self.currency = currency
    }
}

enum ItemType: String {
    case income = "income"
    case outcome = "outcome"
    case savings = "savings"
    case none = "none"
}

enum ItemCategoryType: String {
    case housing = "Housing"
    case grocery = "Grocery"
    case others = "Other"
    case none = "none"
    
    static let all = [housing, grocery, others]
}

class Item: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var userId: String = "" // User().uuid
    @objc dynamic var date: Date = Date()
    @objc dynamic var isIncome: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var descrpt: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var currency: String = ""
    
    @objc dynamic var category: String = ""
    public dynamic var categoryType: ItemCategoryType {
        get {
            return ItemCategoryType(rawValue: self.category) ?? .none
        }
    }
    
    @objc dynamic var type: String = ""
    public dynamic var itemType: ItemType {
        get {
            return ItemType(rawValue: type) ?? .outcome
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required override init() {
        super.init()
    }
    
    init(userId: String,
         isIncome: Bool,
         amount: Double,
         date: Date) {
        self.userId = userId
        self.date = date
        self.type = ItemType.savings.rawValue
        self.isIncome = isIncome
        self.name = "default string for savings type"
        self.descrpt = ""
        self.amount = amount
        self.currency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
        self.category = ItemCategoryType.none.rawValue
    }
    
    init(userId: String,
         type:ItemType,
         name: String,
         description: String,
         amount: Double,
         currency: String,
         category:ItemCategoryType,
         date: Date) {
        self.userId = userId
        self.date = date
        self.type = type.rawValue
        self.name = name
        self.descrpt = description
        self.amount = amount
        self.currency = currency
        self.category = category.rawValue
    }
    
    init(userId: String,
         amount: Double,
         category: ItemCategoryType,
         date: Date) {
        self.userId = userId
        self.date = date
        self.amount = amount
        self.currency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
        self.category = category.rawValue
    }
}

class Note: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var userId: String = "" // User().uuid
    @objc dynamic var date: Date = Date()
    @objc dynamic var descrpt: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required override init() {
        super.init()
    }
    
    init(userId: String,
         date: Date,
         description: String) {
        self.userId = userId
        self.date = date
        self.descrpt = description
    }
}

class ListItems: Object {
    var items = List<String>()
    @objc dynamic var userId: String = "" // User().uuid
   
    required override init() {
        super.init()
    }
    
    init(userId: String,
         items: Array<String>) {
        self.userId = userId
        self.items.append(objectsIn: items)
    }
}
