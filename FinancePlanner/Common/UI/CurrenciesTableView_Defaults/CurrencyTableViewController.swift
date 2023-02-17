//
//  CurrencyTableView.swift
//  FinancePlanner
//
//  Created by Anastasiia on 12.02.2023.
//

import UIKit

class CurrencyTableViewController: UITableViewController {
    var currencies: [Currency] = [Currency]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "currencyTableViewCell")
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        updateUI()
    }
    
    func updateUI() {
        currencies = PreferencesStorage.shared.currencies
        tableView.reloadData()
        selectDefaultCurrency()
    }
    
    func selectDefaultCurrency() {
        DispatchQueue.main.async {
            let defIdx = self.currencies.firstIndex(where: {$0.isDefault}) ?? 0
            self.tableView.selectRow(at: IndexPath(row: defIdx, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
// MARK: - override methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 41
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyTableViewCell", for: indexPath) as! CurrencyTableViewCell
        let item = currencies[indexPath.row]
        cell.configureCell(with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = currencies[indexPath.row]
        PreferencesStorage.shared.currencies = currencies.map { currency in
            currency.isDefault = (currency.name == item.name)
            return currency
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
            PreferencesStorage.shared.currencies.remove(at: indexPath.row)
            self.updateUI()
            UIManager.shared.settingsViewController?.updateUI()
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        selectDefaultCurrency()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
}
