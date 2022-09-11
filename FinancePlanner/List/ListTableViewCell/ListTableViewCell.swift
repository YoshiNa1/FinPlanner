//
//  ListTableViewCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 04.09.2022.
//

import UIKit

protocol ListTableViewCellDelegate {
    func textFieldDidChange(_ textField: UITextField, at indexPath: IndexPath)
}

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleField: ListTextField!
    @IBOutlet weak var iconView: UIImageView!
    
    var delegate: ListTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.selectionStyle = .none
    }
    
    func configureCell(with data: String) {
        let attributedString = NSMutableAttributedString(string: data.replacingOccurrences(of: "<done>", with: ""), attributes: nil)
        if data.contains("<done>") {
            attributedString.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributedString.length))
        }
        titleField.attributedText = attributedString;
        iconView.image = UIImage(named: data.contains("<done>") ? "list_item_checked_image" : "list_item_image")
    }
    
    @objc func textFieldDidChange() {
        if let indexPath = indexPath {
            delegate?.textFieldDidChange(self.titleField, at: indexPath)
        }
    }
}
