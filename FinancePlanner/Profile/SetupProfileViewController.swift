//
//  SetupProfileViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 19.02.2023.
//

import UIKit

class SetupProfileViewController: UIViewController {
    @IBOutlet weak var formBackground: UIView!
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var tableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var amountsView: UIView!
    @IBOutlet weak var balanceField: UITextField!
    @IBOutlet weak var savingsField: UITextField!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var balanceButton: UIButton!
    @IBOutlet weak var savingsButton: UIButton!
    
    private var currencyTableVC: CurrencyTableViewController!
    
    private var selectedCurrencies: [Currency] = [Currency]()
    
    var account: Account? = DataManager.instance.account
    
    private var isCurrenciesSet: Bool = false {
        didSet {
            finishButton.isEnabled = isCurrenciesSet
            balanceField.isEnabled = isCurrenciesSet
            savingsField.isEnabled = isCurrenciesSet
            balanceButton.isEnabled = isCurrenciesSet
            savingsButton.isEnabled = isCurrenciesSet
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountsView.isHidden = false
        if let account = self.account {
            amountsView.isHidden = true
            let currency = Currency(name: account.currency, isDefault: true)
            PreferencesStorage.shared.currencies.append(currency)
        }
        
        self.updateUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: .currencyDidAddToDefaults,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: .currencyDidRemoveFromDefaults,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: .currencyDidSelectFromDefaults,
                                               object: nil)
        
        addKeyboardRecognizer()
        
        formBackground.layer.cornerRadius = 16
        finishButton.layer.cornerRadius = 8
    }
    
    @objc func updateUI() {
        isCurrenciesSet = PreferencesStorage.shared.currencies.count > 0
        
        self.currencyTableVC.updateUI()
        viewWillLayoutSubviews()
        
        setupCurrenciesViews(field: self.balanceField, label: self.balanceLabel, button: self.balanceButton)
        setupCurrenciesViews(field: self.savingsField, label: self.savingsLabel, button: self.savingsButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        self.tableHeight?.constant = self.currencyTableVC.tableView.contentSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CurrencyTableViewController, segue.identifier == "currencyTableVC_profile" {
            self.currencyTableVC = vc
        }
    }
    
    @IBAction func didAddNewCurrency(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConvCurrencyList")
        present(vc, animated: true)
    }
    
    @IBAction func finishClicked(_ sender: Any) {
        if self.account == nil {
            let anyCurrency = PreferencesStorage.shared.currencies.first?.name ?? ""
            
            let balanceText = balanceField.text ?? ""
            let balanceAmount = Double(balanceText) ?? 0
            let balanceCurrency = balanceLabel.text ?? anyCurrency
            
            let savingsText = savingsField.text ?? ""
            let savingsAmount = Double(savingsText) ?? 0
            let savingsCurrency = savingsLabel.text ?? anyCurrency
            
            DataManager.instance.createAccount(with: balanceAmount, balanceCurrency,
                                               and: savingsAmount, savingsCurrency)
        }
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.changeRootViewController(with: "mainTabbarVC")
    }
    
    func setupCurrenciesViews(field: UITextField, label: UILabel, button: UIButton) {
        var currenciesActions = [UIAction]()
        let currencies = PreferencesStorage.shared.currencies
        for currency in currencies {
            currenciesActions.append(UIAction(title: currency.name, image: nil) { (action) in
                label.text = action.title
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: currenciesActions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        
        if field.text == "" {
            label.text = PreferencesStorage.shared.defaultCurrency?.name ?? PreferencesStorage.shared.currencies.first?.name ?? ""
        }
    }
    
}
