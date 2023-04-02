//
//  CalendarViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

class CalendarViewController: UIViewController {
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var daysCollectionView: UICollectionView!
    
    @IBOutlet weak var selectedDateField: UILabel!
    @IBOutlet weak var navButton: UIButton!
    
    @IBOutlet weak var noteFieldView: UIView!
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var dates = [Date]()
    var currentDate = Date()
    var selectedDate = Date() {
        didSet {
            selectedDateField.text = CalendarHelper().dateString(date: selectedDate)
            navButton.isHidden = selectedDate > Date()
            currNote = DataManager.instance.getNote(by: selectedDate)
        }
    }
    
    var currNote: NoteCache? {
        didSet {
            noteField.text = currNote?.descrpt
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        saveButton.layer.cornerRadius = 8
        noteFieldView.layer.cornerRadius = 18
        saveButton.isHidden = true
        
        daysCollectionView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellWithReuseIdentifier: "calendarCell")
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        
        selectedDate = currentDate
        
        reloadUI()
    }
    
    func reloadUI() {
        setDays()
        monthLabel.text = CalendarHelper().monthString(date: currentDate) + ", " + CalendarHelper().yearString(date: currentDate)
        daysCollectionView.reloadData()
    }
    
    func setDays() {
        dates.removeAll()
                
        let daysInMonth = CalendarHelper().daysInMonth(date: currentDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: currentDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        while(count <= 42) {
            let day = count - startingSpaces
            if(count <= startingSpaces || day > daysInMonth) {
                dates.append(Date(timeIntervalSince1970: 0))
            } else {
                let dateByDay = CalendarHelper().dateByDay(day: day, date: currentDate)
                dates.append(dateByDay)
            }
            count += 1
        }
    }
    
    @IBAction func nextMonthClicked(_ sender: Any) {
        currentDate = CalendarHelper().plusMonth(date: currentDate)
        reloadUI()
    }
    
    @IBAction func prevMonthClicked(_ sender: Any) {
        currentDate = CalendarHelper().minusMonth(date: currentDate)
        reloadUI()
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        let noteText = noteField.text ?? ""
        DataManager.instance.setNote(date: selectedDate, description: noteText)
        reloadUI()
        saveButton.isHidden = true
    }
    
    @IBAction func goClicked(_ sender: Any) {
        UIManager.shared.navigateToHomePage(with: selectedDate)
    }
    
}

extension CalendarViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let isEmpty = textView.text.isEmpty
        let isChanged = textView.text != currNote?.descrpt
        saveButton.isHidden = isEmpty || !isChanged
    }
}
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        cell.configureCell(date: dates[indexPath.item])
        if(CalendarHelper().isDate(date: cell.date, equalTo: selectedDate)) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCell
        return cell.date != Date(timeIntervalSince1970: 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCell
        selectedDate = cell.date
    }
}
