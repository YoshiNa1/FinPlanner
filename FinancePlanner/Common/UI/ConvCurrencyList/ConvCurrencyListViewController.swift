//
//  ConvCurrenciesListViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 17.02.2023.
//

import UIKit

extension Notification.Name {
    static let currencyDidAddToDefaults = Notification.Name("CurrencyDidAddToDefaults")
}

class ConvCurrencyListViewController: UIViewController {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currencies: [ConvCurrency] = [ConvCurrency]()
    var filteredCurrencies: [ConvCurrency] = [ConvCurrency]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        filteredCurrencies = currencies
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.layer.cornerRadius = 24
         
        tableView.register(UINib(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "currencyTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.placeholder = "Search Currency..."
        searchBar.delegate = self
        
        updateUI()
    }
    
    func updateUI() {
        currencies = ConvCurrency.all.filter({ convCurr in
            let defCurrencies = PreferencesStorage.shared.currencies.map({$0.getConvCurrency()})
            return !defCurrencies.contains(convCurr)
        })
        tableView.reloadData()
    }

    func close() {
        NotificationCenter.default.post(name: .currencyDidAddToDefaults, object: nil)
        dismiss(animated: true)
    }
}

extension ConvCurrencyListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 41
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyTableViewCell", for: indexPath) as! CurrencyTableViewCell
        let item = filteredCurrencies[indexPath.row]
        cell.configureCell(with: item.rawValue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredCurrencies[indexPath.row]
        let currency = Currency(convCurrency: item)
        PreferencesStorage.shared.currencies.append(currency)
        close()
    }
}

extension ConvCurrencyListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCurrencies = currencies
        } else {
            filteredCurrencies = currencies.filter { curr -> Bool in
                return curr.rawValue.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
