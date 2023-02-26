//
//  SettingsViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet var tableHeight: NSLayoutConstraint!
    
    private var currencyTableVC: CurrencyTableViewController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIManager.shared.setupSettingsPage(self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: .currencyDidAddToDefaults,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: .currencyDidRemoveFromDefaults,
                                               object: nil)
        
        self.updateUI()
    }
    
    @objc func updateUI() {
        self.currencyTableVC.updateUI()
        viewWillLayoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        self.tableHeight?.constant = self.currencyTableVC.tableView.contentSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CurrencyTableViewController, segue.identifier == "currencyTableVC_settings" {
            self.currencyTableVC = vc
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        PreferencesStorage.shared.clearSettings()
        
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.changeRootViewController(with: "setupProfileVC") // TODO: CHANGE TO EMAIL PAGE
    }
    
    @IBAction func didAddNewCurrency(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConvCurrencyList")
        present(vc, animated: true)
    }
    
}
