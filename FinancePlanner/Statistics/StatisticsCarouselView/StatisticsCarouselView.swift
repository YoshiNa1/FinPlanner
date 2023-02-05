//
//  StatisticsCarouselView.swift
//  FinancePlanner
//
//  Created by Anastasiia on 15.01.2023.
//

import UIKit
import Charts

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
    
    var pages = [StatisticsPage]()
    
    var selectedIndex: Int = 0 {
        didSet {
            titleLabel.text = StatisticsType.all[selectedIndex].rawValue
            pageIndicator.currentPage = selectedIndex
            leftBtn.isEnabled = selectedIndex > 0
            rightBtn.isEnabled = selectedIndex < pages.count
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
        
        frequencyType = .day
        
        updateUI()
    }
     
    func updateUI() {
        createStatisticsPages()
        setupStatisticsPages()
        
        pageIndicator.numberOfPages = pages.count
        navigateToPage(0)
    }
    
    func createStatisticsPages() {
        pages.removeAll()
        
        let expItems = DataManager.instance.getStatisticsItemsBy(date: date, frequencyType: frequencyType, type: .outcome)
        let incItems = DataManager.instance.getStatisticsItemsBy(date: date, frequencyType: frequencyType, type: .income)
        let exp_incItems = DataManager.instance.getStatisticsItemsBy(date: date, frequencyType: frequencyType)

        pages.append(createStatisticsPage(with: expItems))
        pages.append(createStatisticsPage(with: incItems))
        pages.append(createStatisticsPage(with: exp_incItems))
    }
    
    func createStatisticsPage(with items: [String:[Item]]) -> StatisticsPage {
        let page: StatisticsPage = StatisticsPage(frame: pagesScrollView.frame)
        
        var chartEntries: [PieChartDataEntry] = [PieChartDataEntry]()
        items.forEach { (key, values) in
            var amount = 0.0
            values.forEach { (item) in
                let itemAmount = item.amount
                let itemCurrency = item.currency
                let defAmount = DataManager.instance.getDefaultAmount(amount: itemAmount, currency: itemCurrency)
                amount += defAmount
            }
            let entry = PieChartDataEntry(value: amount, label: key)
            if amount != 0.0 {
                chartEntries.append(entry)
            }
        }
        page.chartEntries = chartEntries
        return page
    }
    
    func setupStatisticsPages() {
        pagesScrollView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        pagesScrollView.contentSize = CGSize(width: pagesScrollView.frame.width * CGFloat(pages.count), height: pagesScrollView.frame.height)
        pagesScrollView.delegate = self
        pagesScrollView.isPagingEnabled = true
        
        for i in 0 ..< pages.count {
            pages[i].frame = CGRect(x: pagesScrollView.frame.width * CGFloat(i), y: 0, width: pagesScrollView.frame.width, height: pagesScrollView.frame.height)
            pagesScrollView.addSubview(pages[i])
        }
    }
    
    private func scroll(toPage idx: Int) {
        pagesScrollView.scrollRectToVisible(pages[idx].frame, animated: true)
    }
    
    func navigateToPage(_ index: Int) {
        guard index >= 0, index < pages.count else { return }
        scroll(toPage: index)
        selectedIndex = index
    }
    
    @IBAction func rightClicked(_ sender: Any) {
        navigateToPage(selectedIndex + 1)
    }
    
    @IBAction func leftClicked(_ sender: Any) {
        navigateToPage(selectedIndex - 1)
    }
    
    @IBAction func pageControlDidTap(_ pageControl: UIPageControl) {
        navigateToPage(pageControl.currentPage)
    }
}

extension StatisticsCarouselView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / self.frame.width))
        guard pageIndex >= 0, pageIndex < pages.count else { return }
        selectedIndex = pageIndex
    }
}
