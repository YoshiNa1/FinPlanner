//
//  RadioButton.swift
//  FinancePlanner
//
//  Created by Anastasiia on 25.06.2023.
//

import UIKit

class RadioButton: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var radioImage: UIImageView!
    
    var alternateButtons: Array<RadioButton>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RadioButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        unselectAlternateButtons()
    }
    
    func unselectAlternateButtons() {
        if let alternateButtons = alternateButtons {
            self.isSelected = true
            
            for altButton:RadioButton in alternateButtons {
                altButton.isSelected = false
            }
        }
        else {
            toggleButton()
        }
    }
    
    func toggleButton() {
        self.isSelected = !isSelected
    }
    
    var isSelected: Bool = false {
        didSet {
            self.radioImage.image = UIImage(named: isSelected ? "radio_icon_checked" : "radio_icon_unchecked")
        }
    }
}
