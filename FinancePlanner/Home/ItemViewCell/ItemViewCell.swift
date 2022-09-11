//
//  ItemViewCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.09.2022.
//

import UIKit

class ItemViewCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ItemViewCell", owner: self)
        contentView.frame = self.bounds
        addSubview(contentView)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
     
    func configureCell(with model: Item) {
        if(model.type == "savings") {
            iconView.image = UIImage.init(named: model.isIncome ? "savings_income_image" : "savings_outcome_image")
        } else {
            iconView.image = UIImage.init(named: model.type == "income" ? "income_item_image" : "outcome_item_image")
        }
        
        titleLabel.text = model.name
        subtitleLabel.text = model.descrpt
        categoryLabel.text = model.category == "none" ? "" : model.category
        
        let amountString = String(model.amount) + model.currency
//        let defaultCurrency = UserDefaults.shared.defaultCurrency
//        if(model.currency != defaultCurrency) {
//            amountString += "("String(model.amount.toDefault) defaultCurrency")"
//        }
        amountLabel.text = amountString
    }
    
//    func isDefaultCurrency(_ currency: String) -> Bool {
//        return currency == UserDefaults.shared.defaultCurrency
//    }
}
