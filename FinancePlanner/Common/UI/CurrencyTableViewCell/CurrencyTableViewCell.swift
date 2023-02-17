//
//  CurrencyTableViewCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.02.2023.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var defView: UIView!
    var currency: Currency?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        defView.isHidden = !selected
    }
    
    func configureCell(with currency: Currency) {
        self.currency = currency
        titleField.text = currency.name
    }
    
    func configureCell(with title: String) {
        titleField.text = title
    }
}

