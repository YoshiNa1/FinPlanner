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
//    @IBOutlet weak var currencyField: UIView!
    
    var item: Item?
    var type: String = "outcome"
    var currency: String = "USD"

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        categoryField.text = "Other"
        
        formBackground.layer.cornerRadius = 16
        saveButton.layer.cornerRadius = 8
        
        if item != nil {
            nameField.text = item?.name
            descriptionField.text = item?.descrpt
            categoryField.text = item?.category
            amountField.text = String(format: "%2.f", item?.amount ?? 0)
        }
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        var amount: Double = 0
        if let amountText = amountField.text {
            amount = Double(amountText) ?? 0
        }
        
        let item = Item(type: type,
                        name: nameField.text ?? "",
                        description: descriptionField.text ?? "",
                        amount: amount,
                        currency: currency,
                        category: categoryField.text ?? "")
        if let _item = self.item {
            DataManager.instance.update(item: _item, withNewItem: item)
        } else {
            DataManager.instance.add(item: item)
        }
        
        UIManager.shared.homeViewController?.updateUI()
        self.dismiss(animated: true)
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ItemFormViewController {
    func addKeyboardRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
