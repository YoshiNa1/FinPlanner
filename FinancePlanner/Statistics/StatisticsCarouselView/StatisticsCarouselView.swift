//
//  StatisticsCarouselView.swift
//  FinancePlanner
//
//  Created by Anastasiia on 15.01.2023.
//

import UIKit

enum StatisticsType: String {
    case expenses = "Expenses"
    case incomes = "Incomes"
    case exp_inc = "Expenses-Incomes"
    
    static let all = [expenses, incomes, exp_inc]
}

class StatisticsCarouselView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var pagesScrollView: UIScrollView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    var pagesCount: Int {
        get { return StatisticsType.all.count }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            titleLabel.text = StatisticsType.all[selectedIndex].rawValue
            pageIndicator.currentPage = selectedIndex
            leftBtn.isEnabled = selectedIndex > 0
            rightBtn.isEnabled = selectedIndex < pagesCount
        }
    }
    
    var statisticsType: StatisticsType! {
        didSet {
            updateUI()
        }
    }
   
    public var items = [Item]()
    public var monthItems = [[Int:[Item]]]()
    public var yearItems = [[ItemCategoryType:[Item]]]()
    
    public var frequencyType: StatisticsFrequency!
    public var date = Date() {
        didSet {
            updateUI()
        }
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
        Bundle.main.loadNibNamed("StatisticsCarouselView", owner: self)
        contentView.frame = self.bounds
        addSubview(contentView)
        
        pageIndicator.numberOfPages = pagesCount
        selectedIndex = 0
    }
     
    func updateUI() {
        
    }
    
    
    func navigateToPage(_ index: Int) {
        guard index >= 0, index < pagesCount else { return }
        selectedIndex = index
    }
    
    @IBAction func rightClicked(_ sender: Any) {
        navigateToPage(selectedIndex + 1)
    }
    
    @IBAction func leftClicked(_ sender: Any) {
        navigateToPage(selectedIndex - 1)
    }
}
