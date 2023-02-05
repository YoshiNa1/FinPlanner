//
//  BalanceEditFormViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import UIKit

class BalanceEditFormViewController: UIViewController {
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyButton: UIButton!
    
    let currencies = PreferencesStorage.shared.currencies
    
    var account: Account! = DataManager.instance.account
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountField.text = (account.balance == 0.0) ? "" : String(account.balance)
        amountField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       
        saveButton.isEnabled = false
        saveButton.layer.cornerRadius = 8
        
        var currenciesActions = [UIAction]()
        for currency in PreferencesStorage.shared.currencies {
            currenciesActions.append(UIAction(title: currency.name, image: nil) { (action) in
                self.currencyLabel.text = action.title
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: currenciesActions)
        currencyButton.menu = menu
        currencyButton.showsMenuAsPrimaryAction = true
        
        currencyLabel.text = PreferencesStorage.shared.defaultCurrency?.name
    }

    @IBAction func saveClicked(_ sender: Any) {
        if let amountText = amountField.text {
            let amount = Double(amountText) ?? 0
            if amount != account.balance {
                DataManager.instance.updateAccount(withAmount: amount, currency: currencyLabel.text ?? "", isBalance: true)
            }
        }
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let isEmpty = textField.text?.isEmpty {
            self.saveButton.isEnabled = !isEmpty
        }
    }
}

