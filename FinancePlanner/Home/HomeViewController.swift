//
//  HomeViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, ItemViewCellDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionBackground: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var converterButton: UIButton!
    
    let items : Results<Item> = DataManager.instance.items
    var account: Account? = DataManager.instance.account
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIManager.shared.setupHomePage(self)
        
        collectionBackground.layer.backgroundColor = UIColor.init(named: "MainGradient_StartColor")?.cgColor
        collectionBackground.layer.cornerRadius = 24
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateLabel.text = dateFormatter.string(from: Date())
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ItemViewCell.self, forCellWithReuseIdentifier: "itemViewCell")
        
        updateUI()
    }
    
    func updateUI() {
        let defaultCurrency = PreferencesStorage.shared.currencies.first(where: {$0.isDefault})?.name ?? ""
        let defSymbol = ConvCurrency.symbol(for: defaultCurrency)
        if let account = self.account {
            balanceLabel.text = "\(UIManager.shared.format(amount:account.balance))\(defSymbol)"
            savingsLabel.text = "\(UIManager.shared.format(amount:account.savings))\(defSymbol)"
        }
        collectionView.reloadData()
        
        // FOR TEST
        PreferencesStorage.shared.clearSettings()
        PreferencesStorage.shared.currencies = [Currency(name: "USD"),
                                                Currency(name: "UAH", isDefault: true),
                                                Currency(name: "EUR")]
        for currency in PreferencesStorage.shared.currencies {
            print(currency.name)
        }
    }
    
    
    @IBAction func addClicked(_ sender: Any) {
        showVC(withIdentifier: "ItemForm")
    }
    
    @IBAction func ballanceClicked(_ sender: Any) {
        showVC(withIdentifier: "BalanceEditForm")
    }
    
    @IBAction func savingsClicked(_ sender: Any) {
        showVC(withIdentifier: "SavingsEditForm")
    }
    
    @IBAction func converterClicked(_ sender: Any) {
        showVC(withIdentifier: "Converter")
    }
    
    func editItemDidClick(_ viewCell: ItemViewCell) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemForm") as! ItemFormViewController
        vc.currItem = viewCell.model
        present(vc, animated: true)
    }
    
    func showVC(withIdentifier identifier: String) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        present(vc, animated: true)
    }
}

extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 378, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemViewCell", for: indexPath as IndexPath) as! ItemViewCell
        let item = items[indexPath.item]
        cell.configureCell(with: item)
        cell.delegate = self
        return cell
    }
    
}
