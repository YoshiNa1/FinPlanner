//
//  StatisticsViewCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 07.01.2023.
//

import UIKit

class StatisticsViewCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconViewWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var model = Item()
    
    var frequencyType: StatisticsFrequency = .day
    
    let defaultCurrency = PreferencesStorage.shared.currencies.first(where: {$0.isDefault})?.name ?? ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("StatisticsViewCell", owner: self)
        contentView.frame = self.bounds
        addSubview(contentView)
        contentView.isUserInteractionEnabled = false
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
     
    func configureCell(with model: Item, frequencyType: StatisticsFrequency) {
        self.model = model
        self.frequencyType = frequencyType
        
        if(model.itemType == .savings) {
            iconView.image = UIImage.init(named: model.isIncome ? "savings_income_image" : "savings_outcome_image")
        } else {
            iconView.image = UIImage.init(named: model.itemType == .income ? "income_item_image" : "outcome_item_image")
        }
        
        setAmountField()
        
        self.iconViewWidth.constant = frequencyType == .day ? 30 : 0
        self.subtitleLabel.isHidden = frequencyType != .day || model.descrpt.isEmpty
        self.categoryLabel.isHidden = frequencyType != .day
        
        let categoryString = model.categoryType == .none ? "" : model.categoryType.rawValue
        categoryLabel.text = categoryString
        
        titleLabel.text = frequencyType == .year ? categoryString : model.name
        subtitleLabel.text = model.descrpt
    }
    
    func setAmountField() {
        let amountFormatted = UIManager.shared.format(amount: model.amount)
        var amountString = "\(amountFormatted)\(ConvCurrency.symbol(for: model.currency))"
        
        let defAmountFormatted = DataManager.instance.convertAmountToDefault(amount: model.amount, currency: model.currency)
        let defAmountString = "\(defAmountFormatted)\(ConvCurrency.symbol(for: defaultCurrency))"
        
        amountLabel.font = UIFont.systemFont(ofSize: 16) // TEMPORARY SOLUTION. DO REDESIGN!
        
        if frequencyType == .day {
            let isDefaultCurrency = model.currency == defaultCurrency
            if(!isDefaultCurrency) {
                amountString += " (\(defAmountString))"
            }
            amountLabel.font = UIFont.systemFont(ofSize: isDefaultCurrency ? 16 : 14) // TEMPORARY SOLUTION. DO REDESIGN!
        }
        
        amountLabel.text = frequencyType != .year ? amountString : defAmountString
    }
    
}
