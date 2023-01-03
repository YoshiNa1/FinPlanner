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
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyButton: UIButton!
    
    var currItem: Item?
    var type: String = "outcome"
    let currencies = PreferencesStorage.shared.currencies

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        categoryField.text = "Other"
        
        formBackground.layer.cornerRadius = 16
        saveButton.layer.cornerRadius = 8
        
        var currenciesActions = [UIAction]()
        for currency in currencies {
            currenciesActions.append(UIAction(title: currency.name, image: nil) { (action) in
                self.currencyLabel.text = action.title
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: currenciesActions)
        currencyButton.menu = menu
        currencyButton.showsMenuAsPrimaryAction = true
        
        let currency = currencies.first(where: {$0.isDefault})
        currencyLabel.text = currency?.name
        if let item = currItem {
            nameField.text = item.name
            descriptionField.text = item.descrpt
            categoryField.text = item.category
            amountField.text = format(item.amount)
            currencyLabel.text = currencies.first(where: {$0.name == item.currency})?.name
        }
    }
    
    @IBAction func saveClicked(_ sender: Any) {
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
                        category: categoryField.text ?? "",
                        date: UIManager.shared.getHomePageDate())
        if let _item = self.currItem {
            let amountForUpdate = item.amount - _item.amount
            DataManager.instance.updateAccount(withItem: item, amount: amountForUpdate)
            
            DataManager.instance.update(item: _item, withNewItem: item)
            
        } else {
            DataManager.instance.updateAccount(withItem: item, amount: amount)
            
            DataManager.instance.add(item: item)
        }
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
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
