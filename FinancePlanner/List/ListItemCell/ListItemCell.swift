//
//  ListItemCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit


class ListItemCell: UICollectionViewCell {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var iconView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ListItemCell", owner: self)
        contentView.frame = self.bounds
        addSubview(contentView)
    }
    
    func configureCell(with data: String) {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:data.replacingOccurrences(of: "<done>", with: ""))
        if data.contains("<done>") {
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributedString.length))
        }
        titleField.attributedText = attributedString;
        iconView.image = UIImage(named: data.contains("<done>") ? "list_item_checked_image" : "list_item_image")
    }
}
