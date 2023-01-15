//
//  StatisticsViewHeader.swift
//  FinancePlanner
//
//  Created by Anastasiia on 15.01.2023.
//

import UIKit

class StatisticsViewHeader: UICollectionReusableView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navButton: UIButton!
    
    var date = Date()
//    var frequencyType: StatisticsFrequency = .day
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("StatisticsViewHeader", owner: self)
        contentView.frame = self.bounds
        addSubview(contentView)
    }
     
    func configureHeader(with date: Date, frequencyType: StatisticsFrequency) {
        self.date = date
        self.navButton.isHidden = frequencyType == .year

        let dateString = frequencyType == .year ? CalendarHelper().monthString(date: date) :
                                                    CalendarHelper().dateString(date: date)
        titleLabel.text = dateString
    }
    
    @IBAction func goClicked(_ sender: Any) {
        UIManager.shared.navigateToHomePage(with: self.date)
    }
}
