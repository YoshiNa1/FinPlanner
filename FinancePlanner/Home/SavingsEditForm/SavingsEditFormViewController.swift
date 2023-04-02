//
//  SavingsEditFormViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import UIKit

class SavingsEditFormViewController: UIViewController {
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var transactionAmountField: UITextField!
    
    @IBOutlet weak var replenishButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyButton: UIButton!
    
    @IBOutlet weak var transactionCurrencyLabel: UILabel!
    @IBOutlet weak var transactionCurrencyButton: UIButton!
    
    let currencies = PreferencesStorage.shared.currencies
    
    var profile: ProfileCache! = DataManager.instance.profile
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        amountField.text = (profile.savings == 0.0) ? "" : String(profile.savings)
        amountField.addTarget(self, action: #selector(amountFieldDidChange(_:)), for: .editingChanged)
        transactionAmountField.addTarget(self, action: #selector(transactionAmountFieldDidChange(_:)), for: .editingChanged)
        
        saveButton.isEnabled = false
        replenishButton.isEnabled = false
        withdrawButton.isEnabled = false
        
        saveButton.layer.cornerRadius = 8
        replenishButton.layer.cornerRadius = 10
        withdrawButton.layer.cornerRadius = 10
        
        setupCurrenciesViews(label: self.currencyLabel, button: self.currencyButton)
        setupCurrenciesViews(label: self.transactionCurrencyLabel, button: self.transactionCurrencyButton)
    }

    func setupCurrenciesViews(label: UILabel, button: UIButton) {
        var currenciesActions = [UIAction]()
        for currency in currencies {
            currenciesActions.append(UIAction(title: currency.name, image: nil) { (action) in
                label.text = action.title
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: currenciesActions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        
        label.text = PreferencesStorage.shared.defaultCurrency?.name
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        save()
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
    }
   
    func save() {
        if let amountText = amountField.text {
            let amount = Double(amountText) ?? 0
            if amount != profile.savings {
                DataManager.instance.updateProfile(withAmount: amount, currency: currencyLabel.text ?? "", isBalance: false)
            }
        }
    }
    @IBAction func replenishClicked(_ sender: Any) {
        save()
        var transactionAmount = 0.0
        if let amountText = transactionAmountField.text {
            transactionAmount = Double(amountText) ?? 0
        }
        DataManager.instance.updateProfile(withTransactionAmount: transactionAmount, currency: transactionCurrencyLabel.text ?? "", isWithdraw: false)
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
    }
    
    @IBAction func withdrawClicked(_ sender: Any) {
        save()
        var transactionAmount = 0.0
        if let amountText = transactionAmountField.text {
            transactionAmount = Double(amountText) ?? 0
        }
        DataManager.instance.updateProfile(withTransactionAmount: transactionAmount, currency: transactionCurrencyLabel.text ?? "", isWithdraw: true)
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func amountFieldDidChange(_ textField: UITextField) {
        if let isEmpty = textField.text?.isEmpty {
            self.saveButton.isEnabled = !isEmpty
        }
    }
    @objc func transactionAmountFieldDidChange(_ textField: UITextField) {
        if let isEmpty = textField.text?.isEmpty {
            self.replenishButton.isEnabled = !isEmpty
            self.withdrawButton.isEnabled = !isEmpty
        }
    }
}
