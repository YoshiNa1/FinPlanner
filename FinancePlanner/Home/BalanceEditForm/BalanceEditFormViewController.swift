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
    
    var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        configureUI()
    }

    func configureUI() {
        DataManager.instance.getProfile { profile, _ in
            if let profile = profile {
                self.profile = profile
                self.amountField.text = (profile.balance == 0.0) ? "" : String(profile.balance)
            }
        }
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
        let amount = amountField.getDoubleFromField()
        let currency = currencyLabel.text ?? ""
        if amount != profile?.balance {
            DataManager.instance.updateProfile(withAmount: amount, currency: currency, isBalance: true) { _, _ in
                UIManager.shared.homeViewController?.updateUI()
                self.dismiss(animated: true)
            }
        } else {
            self.dismiss(animated: true)
        }
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

