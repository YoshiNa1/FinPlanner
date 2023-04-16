//
//  ItemFormViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 18.09.2022.
//

import UIKit

class ItemFormViewController: UIViewController {
    @IBOutlet weak var formBackground: UIView!
    
//    @IBOutlet weak var radioControl: RadioControll!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyButton: UIButton!
    
    var currItem: Item?
    var type: ItemType = .outcome
    let currencies = PreferencesStorage.shared.currencies

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        formBackground.layer.cornerRadius = 16
        saveButton.layer.cornerRadius = 8
        
        setCurrenciesView()
        setCategoriesView()
        
        if let item = currItem {
            nameField.text = item.name
            descriptionField.text = item.description
            categoryField.text = item.categoryType.rawValue
            amountField.text = format(item.amount)
            currencyLabel.text = currencies.first(where: {$0.name == item.currency})?.name
        }
    }
    
    func setCurrenciesView() {
        var currenciesActions = [UIAction]()
        for currency in currencies {
            currenciesActions.append(UIAction(title: currency.name, image: nil) { (action) in
                self.currencyLabel.text = action.title
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: currenciesActions)
        currencyButton.menu = menu
        currencyButton.showsMenuAsPrimaryAction = true
        
        currencyLabel.text = PreferencesStorage.shared.defaultCurrency?.name
    }
    
    func setCategoriesView() {
        var categoriesActions = [UIAction]()
        for category in ItemCategoryType.all {
            categoriesActions.append(UIAction(title: category.rawValue, image: nil) { (action) in
                self.categoryField.text = action.title
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: categoriesActions)
        categoryButton.menu = menu
        categoryButton.showsMenuAsPrimaryAction = true
        
        categoryField.text = ItemCategoryType.others.rawValue
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        let completion: () -> Void = {
            UIManager.shared.homeViewController?.updateUI()
            self.dismiss(animated: true)
        }
        var amount: Double = 0
        if let amountText = amountField.text {
            let formatter = NumberFormatter()
            formatter.decimalSeparator = ","
            let grade = formatter.number(from: amountText)
            if let doubleGrade = grade?.doubleValue {
                amount = doubleGrade
            } else {
                amount = Double(amountText) ?? 0
            }
        }
        let item = Item(type: type,
                        name: nameField.text ?? "",
                        description: descriptionField.text ?? "",
                        amount: amount,
                        currency: currencyLabel.text ?? "",
                        category: ItemCategoryType(rawValue: categoryField.text ?? "") ?? .none,
                        date: UIManager.shared.getHomePageDate())
        
        if let _item = self.currItem {
            let amountForUpdate = item.amount - _item.amount
            DataManager.instance.updateProfile(withItem: item, amount: amountForUpdate) { _, _ in }
            DataManager.instance.update(item: _item, withNewItem: item) { _, _ in
                completion()
            }
            
        } else {
            DataManager.instance.updateProfile(withItem: item, amount: amount) { _, _ in }
            DataManager.instance.add(item: item) { _, _ in
                completion()
            }
        }
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    public func format(_ value : Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let formattedString = formatter.string(from: NSNumber(value: value))
        return formattedString ?? ""
    }
}
