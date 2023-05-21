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
    
    var profile: Profile?
    
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
        
        DataManager.instance.getProfile(completion: { profile, _ in
            if let profile = profile {
                self.profile = profile
                self.amountsView.isHidden = true
                if PreferencesStorage.shared.currencies.isEmpty {
                    let currency = Currency(name: profile.currency, isDefault: true)
                    PreferencesStorage.shared.currencies.append(currency)
                }
            } else {
                self.amountsView.isHidden = false
            }
        })
        
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
        if self.profile == nil {
            let anyCurrency = PreferencesStorage.shared.currencies.first?.name ?? ""
            
            let balanceAmount = balanceField.getDoubleFromField()
            let balanceCurrency = balanceLabel.text ?? anyCurrency
            
            let savingsAmount = savingsField.getDoubleFromField()
            let savingsCurrency = savingsLabel.text ?? anyCurrency
            
            DataManager.instance.createProfile(with: balanceAmount, balanceCurrency,
                                               and: savingsAmount, savingsCurrency) { _, _ in }
        }
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        DataManager.instance.syncAllData { error in
            if let error = error {
                print("Sync data error: \(error.localizedDescription)")
            }
            sceneDelegate?.changeRootViewController(with: "mainTabbarVC")
        }
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
