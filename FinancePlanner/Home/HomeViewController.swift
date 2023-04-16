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
    
    var date: Date = Date() {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateLabel.text = dateFormatter.string(from: date)
            updateUI()
        }
    }
    var items = [Item]()
    var profile: Profile?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIManager.shared.setupHomePage(self)
        
        date = Date()
        
        collectionBackground.layer.backgroundColor = UIColor.init(named: "MainGradient_StartColor")?.cgColor
        collectionBackground.layer.cornerRadius = 24
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ItemViewCell.self, forCellWithReuseIdentifier: "itemViewCell")
        
        updateUI()
    }
    
    func updateUI() {
        DataManager.instance.getProfile { profile, _ in
            if let profile = profile {
                self.profile = profile
                let defSymbol = ConvCurrency.symbol(for: profile.currency)
                self.balanceLabel.text = "\(UIManager.shared.format(amount:profile.balance))\(defSymbol)"
                self.savingsLabel.text = "\(UIManager.shared.format(amount:profile.savings))\(defSymbol)"
            }
        }
        
        DataManager.instance.getItemsBy(date: date) { items, error in
            self.items = items
            self.collectionView.reloadData()
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
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemViewCell", for: indexPath as IndexPath) as! ItemViewCell
        let item = items[indexPath.item]
        cell.configureCell(with: item)
        cell.delegate = self
        return cell
    }
    
}
