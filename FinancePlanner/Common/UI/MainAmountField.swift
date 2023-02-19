//
//  MainAmountField.swift
//  FinancePlanner
//
//  Created by Anastasiia on 19.02.2023.
//

import UIKit

class MainAmountField: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyButton: UIButton!
    
    private var currencies = PreferencesStorage.shared.currencies
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MainAmountField", owner: self)
        contentView.frame = self.bounds
        addSubview(contentView)
        
        setupViews(label: currencyLabel, button: currencyButton)
    }
    
    
    func setupViews(label: UILabel, button: UIButton) {
        var currenciesActions = [UIAction]()
        for currency in currencies {
            currenciesActions.append(UIAction(title: currency.name, image: nil) { (action) in
                label.text = action.title
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: currenciesActions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        
        label.text = PreferencesStorage.shared.defaultCurrency?.name
    }
    
}
