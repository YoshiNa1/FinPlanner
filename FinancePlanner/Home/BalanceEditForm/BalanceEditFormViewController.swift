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
    
    var account: Account! = DataManager.instance.account
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountField.text = (account.balance == 0.0) ? "" : String(account.balance)
        amountField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       
        saveButton.isEnabled = false
        saveButton.layer.cornerRadius = 8
    }
    

    @IBAction func saveClicked(_ sender: Any) {
        if let amountText = amountField.text {
            let amount = Double(amountText) ?? 0
            if amount != account.balance {
                DataManager.instance.updateAccount(withAmount: amount, isBalance: true)
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

