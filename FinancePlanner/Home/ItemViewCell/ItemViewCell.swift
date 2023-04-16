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
    
    var model: Item?
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
        if(model.itemType == .savings) {
            iconView.image = UIImage.init(named: model.isIncome ? "savings_income_image" : "savings_outcome_image")
        } else {
            iconView.image = UIImage.init(named: model.itemType == .income ? "income_item_image" : "outcome_item_image")
        }
        
        titleLabel.text = model.name
        
        subtitleLabel.text = model.description
        subtitleLabel.isHidden = model.description.isEmpty
        
        categoryLabel.text = model.categoryType.rawValue
        categoryLabel.isHidden = model.categoryType == .none
        
        let amountFormatted = UIManager.shared.format(amount: model.amount)
        var amountString = "\(amountFormatted)\(ConvCurrency.symbol(for: model.currency))"
       
        let defaultCurrency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
        let isDefaultCurrency = model.currency == defaultCurrency
        if(!isDefaultCurrency) {
            let defAmountString = DataManager.instance.convertAmountToDefault(amount: model.amount, currency: model.currency)
            amountString += " (\(defAmountString)\(ConvCurrency.symbol(for: defaultCurrency)))"
        }
        amountLabel.font = UIFont.systemFont(ofSize: isDefaultCurrency ? 16 : 14) // TEMPORARY SOLUTION. DO REDESIGN!
        amountLabel.text = amountString
    }
        
    func delete() {
        if let model = model {
            DataManager.instance.updateProfile(withItem: model, amount: model.amount, isRemoval: true) {_, _ in}
            DataManager.instance.delete(item: model) { _, _ in
                UIManager.shared.homeViewController?.updateUI()
            }
        }
    }
    
    func edit() {
        delegate?.editItemDidClick(self)
    }
}
