//
//  StatisticsViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

enum StatisticsFrequency: String {
    case day = "Day"
    case month = "Month"
    case year = "Year"
}

class StatiscticsTableSection {
    var title: Date = Date()
    var childs: [Item] = [Item]()
    
    init(title: Date,
         childs: [Item]) {
        self.title = title
        self.childs = childs
    }
}

class StatisticsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyCollectionView: UIView!
    
    @IBOutlet weak var carouselView: StatisticsCarouselView!
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var datePickerView: UIView!
    
    var dateComponentsCount = 0
    var (dayComponent, monthComponent, yearComponent) = (0, 0, 0)
      
    var frequencyType: StatisticsFrequency! {
        didSet {
            var componentsCount = 3
            switch self.frequencyType {
            case .month:
                componentsCount = 2
            case .year:
                componentsCount = 1
            default:
                break
            }
            self.dateComponentsCount = componentsCount
            (dayComponent, monthComponent, yearComponent) = getComponentsIndexes()
            
            self.datePicker.reloadAllComponents()
            setSelectedDate()
            selectDatePickerRows()
            self.frequencyLabel.text = frequencyType.rawValue
        }
    }
  
    var days: [Int]!
    let months = CalendarHelper().months()
    let years = CalendarHelper().years()
    
    var selectedDay: Int = 0
    var selectedMonth: Int = 0
    var selectedYear: Int = 0
    
    var selectedDate = Date() {
        didSet {
            days = CalendarHelper().days(for: selectedDate)
            
            var dateString = CalendarHelper().dateString(date: selectedDate, long: true)
            switch self.frequencyType {
            case .month:
                dateString = CalendarHelper().monthAndYearString(date: selectedDate)
            case .year:
                dateString = CalendarHelper().yearString(date: selectedDate)
            default:
                break
            }
            
            dateLabel.text = dateString
        }
    }
    
    var items = [Item]()
    var monthItems = [[Int:[Item]]]()
    var yearItems = [[ItemCategoryType:[Item]]]()
    
    var sections = [StatiscticsTableSection]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDate = Date()
        (selectedDay, selectedMonth, selectedYear) = CalendarHelper().componentsByDate(selectedDate)
        
        datePicker.delegate = self
        datePicker.dataSource = self
        datePickerView.isHidden = true
        
        setupFrequencyView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StatisticsViewCell.self, forCellWithReuseIdentifier: "statisticsViewCell")
        collectionView.register(StatisticsViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "statisticsViewHeader")
        
        updateUI()
    }
    
    func updateUI() {
        self.sections.removeAll()
        switch frequencyType {
        case .day:
            self.items = DataManager.instance.getItemsBy(date: selectedDate)
            self.carouselView.items = items
            let section = StatiscticsTableSection(title: selectedDate, childs: items)
            self.sections.append(section)
            
            self.emptyCollectionView.isHidden = !items.isEmpty
            self.carouselView.isHidden = items.isEmpty
        case .month:
            self.monthItems = DataManager.instance.getMonthItemsBy(date: selectedDate)
            self.carouselView.monthItems = monthItems
            
            for day in 1...monthItems.count {
                let dict = monthItems[day - 1]
                var dayItems = [Item]()
                dict.values.forEach { (items) in
                    dayItems.append(contentsOf: items)
                }

                let date = dayItems.first?.date ?? Date()
                let section = StatiscticsTableSection(title: date, childs: dayItems)
                if !section.childs.isEmpty {
                    self.sections.append(section)
                }
            }
            
            self.emptyCollectionView.isHidden = !monthItems.isEmpty
            self.carouselView.isHidden = monthItems.isEmpty
        case .year:
            self.yearItems = DataManager.instance.getYearItemsBy(date: selectedDate)
            self.carouselView.yearItems = yearItems
            
            for month in 1...yearItems.count {
                let dict = yearItems[month - 1]
                var monthItems = [Item]()
                
                for (_, items) in dict {
                    if !items.isEmpty {
                        let item = DataManager.instance.createYearItem(with: items)
                        monthItems.append(item)
                    }
                }
                
                let date = monthItems.first?.date ?? Date()
                let section = StatiscticsTableSection(title: date, childs: monthItems)
                if !section.childs.isEmpty {
                    self.sections.append(section)
                }
            }
            
            self.emptyCollectionView.isHidden = !yearItems.isEmpty
            self.carouselView.isHidden = yearItems.isEmpty
        default:
            break
        }
        
        self.collectionView.reloadData()
        
        self.carouselView.frequencyType = frequencyType
        self.carouselView.date = selectedDate
    }
    
    
    func setupFrequencyView() {
        let frequencies = [StatisticsFrequency.day.rawValue,
                           StatisticsFrequency.month.rawValue,
                           StatisticsFrequency.year.rawValue]
        
        var actions = [UIAction]()
        
        for frequency in frequencies {
            actions.append(UIAction(title: frequency, image: nil) { (action) in
                self.frequencyType = StatisticsFrequency(rawValue: action.title)
            })
        }
        let menu = UIMenu(title: "", options: .displayInline, children: actions)
        frequencyButton.menu = menu
        frequencyButton.showsMenuAsPrimaryAction = true
        
        frequencyType = .day
    }
    
    
    func getComponentsIndexes() -> (Int, Int, Int) {
        let dayIndex = 0
        var monthIndex = 0
        var yearIndex = 0
        switch self.frequencyType {
        case .day:
            monthIndex = 1
            yearIndex = 2
        case .month:
            yearIndex = 1
        default:
            break
        }
        return (dayIndex, monthIndex, yearIndex)
    }
    
    @IBAction func showDatePickerClicked(_ sender: Any) {
        datePickerView.isHidden = false
        selectDatePickerRows()
    }
    
    @IBAction func hideDatePickerClicked(_ sender: Any) {
        setSelectedDate()
        datePickerView.isHidden = true
    }
    
    func setSelectedDate() {
        let (day, month, year) = (self.selectedDay, self.selectedMonth, self.selectedYear)
        var date = self.selectedDate
        switch frequencyType {
        case .year:
            date = CalendarHelper().dateByComponents(year: year, date: self.selectedDate)
        case .month:
            date = CalendarHelper().dateByComponents(month: month, year: year, date: self.selectedDate)
        case .day:
            date = CalendarHelper().dateByComponents(day: day, month: month, year: year, date: self.selectedDate)
        default:
            break
        }
        self.selectedDate = date
        
        updateUI()
    }
    
    func selectDatePickerRows() {
        let yearIdx = years.firstIndex(of: selectedYear) ?? 0
        datePicker.selectRow(yearIdx, inComponent: yearComponent, animated: false)
        
        if dateComponentsCount > 1 {
            datePicker.selectRow(selectedMonth - 1, inComponent: monthComponent, animated: false)
        }
        if dateComponentsCount == 3 {
            let dayIdx = days.firstIndex(of: selectedDay) ?? 0
            datePicker.selectRow(dayIdx, inComponent: dayComponent, animated: false)
        }
    }
}

extension StatisticsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == yearComponent {
            return years.count
        }
        if component == monthComponent {
            return months.count
        }
        if component == dayComponent {
            return days.count
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.dateComponentsCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == yearComponent {
            return "\(years[row])"
        }
        if component == monthComponent {
            return "\(months[row])"
        }
        if component == dayComponent {
            return "\(days[row])"
        }
        return ""
   }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedYear = years[pickerView.selectedRow(inComponent: yearComponent)]

        if dateComponentsCount > 1 {
            self.selectedMonth = pickerView.selectedRow(inComponent:monthComponent) + 1
        }
        if dateComponentsCount == 3 {
            self.selectedDay = days[pickerView.selectedRow(inComponent: dayComponent)]
        }
    }
}


extension StatisticsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.childs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 366, height: 41)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 366, height: 24)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statisticsViewCell", for: indexPath as IndexPath) as! StatisticsViewCell
        let item = sections[indexPath.section].childs[indexPath.item]
        cell.configureCell(with: item, frequencyType: self.frequencyType)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var header : StatisticsViewHeader! = nil
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "statisticsViewHeader", for: indexPath) as? StatisticsViewHeader
            let headerTitle = self.sections[indexPath.section].title
            header.configureHeader(with: headerTitle, frequencyType: self.frequencyType)
        }
        
        return header
    }
    
}
