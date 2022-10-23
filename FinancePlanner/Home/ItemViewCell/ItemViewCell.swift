//
//  ItemViewCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.09.2022.
//

import UIKit

protocol ItemViewCellDelegate {
    func editItemDidClick(_ viewCell: ItemViewCell)
}

class ItemViewCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var model = Item()
    var delegate: ItemViewCellDelegate?
    
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
        contentView.isUserInteractionEnabled = false
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        let deleteItem = UIAction(title: "Delete", image: UIImage(named: "")) { (action) in self.delete() }
        let editItem = UIAction(title: "Edit", image: UIImage(named: "")) { (action) in self.edit() }
        let menu = UIMenu(title: "", options: .displayInline, children: [deleteItem, editItem])
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
     
    func configureCell(with model: Item) {
        self.model = model
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
    
    func delete() {
        DataManager.instance.delete(item: self.model)
        UIManager.shared.homeViewController?.updateUI()
    }
    
    func edit() {
        delegate?.editItemDidClick(self)
    }
    
    
}
