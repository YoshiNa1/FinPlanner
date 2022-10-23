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
    
    var account: Account! = DataManager.instance.account
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountField.text = (account.savings == 0.0) ? "" : String(account.savings)
        amountField.addTarget(self, action: #selector(amountFieldDidChange(_:)), for: .editingChanged)
        transactionAmountField.addTarget(self, action: #selector(transactionAmountFieldDidChange(_:)), for: .editingChanged)
        
        saveButton.isEnabled = false
        replenishButton.isEnabled = false
        withdrawButton.isEnabled = false
        
        saveButton.layer.cornerRadius = 8
        replenishButton.layer.cornerRadius = 10
        withdrawButton.layer.cornerRadius = 10
    }

    @IBAction func saveClicked(_ sender: Any) {
        save()
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
    }
   
    func save() {
        if let amountText = amountField.text {
            let amount = Double(amountText) ?? 0
            if amount != account.savings {
                DataManager.instance.updateAccount(withAmount: amount, isBalance: false)
            }
        }
    }
    @IBAction func replenishClicked(_ sender: Any) {
        save()
        var transactionAmount = 0.0
        if let amountText = transactionAmountField.text {
            transactionAmount = Double(amountText) ?? 0
        }
        DataManager.instance.updateAccount(withTransactionAmount: transactionAmount, isWithdraw: false)
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
    }
    
    @IBAction func withdrawClicked(_ sender: Any) {
        save()
        var transactionAmount = 0.0
        if let amountText = transactionAmountField.text {
            transactionAmount = Double(amountText) ?? 0
        }
        DataManager.instance.updateAccount(withTransactionAmount: transactionAmount, isWithdraw: true)
        
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