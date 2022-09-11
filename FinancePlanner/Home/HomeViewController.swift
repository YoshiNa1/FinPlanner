//
//  HomeViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit
import RealmSwift

class Item: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var type: String = ""
    @objc dynamic var isIncome: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var descrpt: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var currency: String = ""
    @objc dynamic var category: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required override init() {
        super.init()
    }
    
    init(isIncome: Bool,
         amount: Double) {
        self.date = Date()
        self.type = "savings"
        self.isIncome = isIncome
        self.name = "default string for savings type"
        self.descrpt = ""
        self.amount = amount
        self.currency = "default currency"
        self.category = "none"
    }
    
    init(type:String,
         name: String,
         description: String,
         amount: Double,
         currency: String,
         category: String) {
        self.date = Date()
        self.type = type
        self.name = name
        self.descrpt = description
        self.amount = amount
        self.currency = currency
        self.category = category
    }
}

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionBackground: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var converterButton: UIButton!
    
    let realm = try! Realm()
    var items : Results<Item>!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionBackground.layer.backgroundColor = UIColor.init(named: "MainGradient_StartColor")?.cgColor
        collectionBackground.layer.cornerRadius = 24
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateLabel.text = dateFormatter.string(from: Date())
        
        items = self.realm.objects(Item.self)
        
        let item1 = Item(type: "income",
                         name: "Salary",
                         description: "may-june",
                         amount: 600,
                         currency: "$",
                         category: "salary")
        let item2 = Item(type: "outcome",
                         name: "Grocery",
                         description: "products for the week",
                         amount: 800,
                         currency: "UAH",
                         category: "grocery")
        let item3 = Item(isIncome: true,
                         amount: 2500)
        
        try! self.realm.write({
            realm.deleteAll()
            realm.add([item1, item2, item3], update: .all)
        })
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ItemViewCell.self, forCellWithReuseIdentifier: "itemViewCell")
        
        updateUI()
    }
    
    func updateUI() {
        collectionView.reloadData()
    }
    
    @IBAction func addClicked(_ sender: Any) {
        //modal
    }
    
    @IBAction func ballanceClicked(_ sender: Any) {
        //modal
    }
    
    @IBAction func savingsClicked(_ sender: Any) {
        //modal
    }
    
    @IBAction func converterClicked(_ sender: Any) {
        //modal
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
        return cell
    }
    
}
