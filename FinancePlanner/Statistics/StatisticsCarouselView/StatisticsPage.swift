//
//  StatisticsPage.swift
//  FinancePlanner
//
//  Created by Anastasiia on 15.01.2023.
//

import UIKit
import Charts

class StatisticsPage: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    public var chartEntries: [PieChartDataEntry] = [PieChartDataEntry]() {
        didSet {
            let dataSet: PieChartDataSet = PieChartDataSet(entries: chartEntries)
            dataSet.drawIconsEnabled = false
            dataSet.colors = ChartColorTemplates.pastel()
            dataSet.label = ""
            
//            let formatter = NumberFormatter()
//            formatter.numberStyle = .percent
//            formatter.maximumFractionDigits = 1
//            formatter.multiplier = 1
//            formatter.percentSymbol = " %"
//
//            dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
            dataSet.valueFont = UIFont(name: "HelveticaNeue-Light", size: 11) ?? .systemFont(ofSize: 11)
            dataSet.valueTextColor = UIColor(named: "TitleFontColor") ?? .clear
            
            pieChart.data = PieChartData(dataSet: dataSet)
            
            noDataLbl.isHidden = !chartEntries.isEmpty
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("StatisticsPage", owner: self)
        contentView.frame = self.bounds
        addSubview(contentView)
        
        noDataLbl.isHidden = true
        
        pieChart.drawHoleEnabled = false
    }
}
