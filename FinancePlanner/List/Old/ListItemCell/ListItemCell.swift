//
//  ListItemCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

protocol ListItemCellDelegate {
    func addNewCell(at indexPath: IndexPath)
    func removeCurrentCell(at indexPath: IndexPath)
    
    func textFieldDidChange(_ textField:UITextField, at indexPath: IndexPath )
}

class ListItemCell: UICollectionViewCell {
    @IBOutlet weak var titleField: ListTextField!
    @IBOutlet weak var iconView: UIImageView!
    
    var delegate: ListItemCellDelegate?
    var indexPath: IndexPath?
    
    var data: String = "" {
        didSet {
            let attributedString = NSMutableAttributedString(string: data.replacingOccurrences(of: "<done>", with: ""), attributes: nil)
            if isDone {
                attributedString.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributedString.length))
            }
            titleField.attributedText = attributedString;
            iconView.image = UIImage(named: isDone ? "list_item_checked_image" : "list_item_image")
        }
    }
  
    var isDone: Bool {
        return data.contains("<done>")
    }
    
    var isNew: Bool {
        return data.contains("<new>")
    }
    
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
        
        titleField.listDelegate = self
    }

}

extension ListItemCell: ListTextFieldDelegate  {
    func textFieldDidReturn(_ textField: UITextField) {
        if let indexPath = indexPath {
            delegate?.addNewCell(at: indexPath)
        }
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        if let indexPath = indexPath {
            delegate?.removeCurrentCell(at: indexPath)
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if let indexPath = indexPath {
            delegate?.textFieldDidChange(textField, at: indexPath)
        }
    }
    
}
