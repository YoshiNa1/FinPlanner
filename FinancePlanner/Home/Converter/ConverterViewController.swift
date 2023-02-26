//
//  ConverterViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import UIKit

class ConverterViewController: UIViewController {
    @IBOutlet weak var firstField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    
    var firstSelectedCurrency: ConvCurrency?
    var secondSelectedCurrency: ConvCurrency?
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        configureUI()
    }
   
    func configureUI() {
        firstField.addTarget(self, action: #selector(firstTextFieldDidChange(_:)), for: .editingChanged)
        secondField.addTarget(self, action: #selector(secondTextFieldDidChange(_:)), for: .editingChanged)
        
        let firstDefCurrency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
        let secondDefCurrency = PreferencesStorage.shared.currencies.first(where: { !$0.isDefault })?.name ?? ""
        
        firstSelectedCurrency = ConvCurrency.all.first(where: {$0.rawValue == firstDefCurrency})
        secondSelectedCurrency = ConvCurrency.all.first(where: {$0.rawValue == secondDefCurrency})
        
        setupCurrenciesMenu(firstBtn, lbl: firstLbl, defCurrency: firstDefCurrency) { curr in
            self.firstSelectedCurrency = curr
            if self.firstField.isFocused {
                self.convertFirstField()
            } else {
                self.convertSecondField()
            }
        }
        setupCurrenciesMenu(secondBtn, lbl: secondLbl, defCurrency: secondDefCurrency) { curr in
            self.secondSelectedCurrency = curr
            if self.firstField.isFocused {
                self.convertSecondField()
            } else {
                self.convertFirstField()
            }
        }
    }
    
    func setupCurrenciesMenu(_ btn: UIButton, lbl: UILabel, defCurrency: String, completion: @escaping (ConvCurrency) -> Void) {
        var currenciesActions = [UIAction]()
        for currency in ConvCurrency.all {
            currenciesActions.append(UIAction(title: currency.rawValue, image: nil) { (action) in
                lbl.text = action.title
                completion(currency)
            })
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: currenciesActions)
        btn.menu = menu
        btn.showsMenuAsPrimaryAction = true
        
        lbl.text = ConvCurrency.all.first(where: {$0.rawValue == defCurrency})?.rawValue
    }
    
    func convertFirstField() {
        self.convertAmount(from: self.secondField, to: self.firstField, valueCurrency: self.secondSelectedCurrency!, outputCurrency: self.firstSelectedCurrency!)
    }
    func convertSecondField() {
        self.convertAmount(from: self.firstField, to: self.secondField, valueCurrency: self.firstSelectedCurrency!, outputCurrency: self.secondSelectedCurrency!)
    }
    
    func convertAmount(from firstField: UITextField, to secondField: UITextField, valueCurrency: ConvCurrency, outputCurrency: ConvCurrency) {
        var amount: Double = 0
        if let amountText = firstField.text {
            let formatter = NumberFormatter()
            formatter.decimalSeparator = ","
            let grade = formatter.number(from: amountText)
            if let doubleGrade = grade?.doubleValue {
                amount = doubleGrade
            } else {
                amount = Double(amountText) ?? 0
            }
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let convertedAmount = appDelegate.currencyConverter.convertAndFormat(amount, valueCurrency:valueCurrency, outputCurrency: outputCurrency, numberStyle: .none, decimalPlaces: 2)
            secondField.text = convertedAmount
        }
    }
    
    @objc func firstTextFieldDidChange(_ textField: UITextField) {
        convertSecondField()
    }
    @objc func secondTextFieldDidChange(_ textField: UITextField) {
        convertFirstField()
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
