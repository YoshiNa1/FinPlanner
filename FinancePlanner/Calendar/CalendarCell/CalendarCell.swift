//
//  CalendarCell.swift
//  FinancePlanner
//
//  Created by Anastasiia on 09.12.2022.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var noteIndicatorView: UIImageView!
    
    var date: Date!
    var hasNote: Bool = false {
        didSet {
            self.noteIndicatorView.isHidden = !hasNote
        }
    }
    override var isSelected: Bool {
        didSet {
            self.selectedImage.isHidden = !isSelected
        }
    }
    
    func configureCell(date: Date) {
        self.date = date
        self.noteIndicatorView.isHidden = true
        if(date == Date(timeIntervalSince1970: 0)) {
            self.dayLabel.text = ""
        } else {
            let day = CalendarHelper().dayOfMonth(date: date)
            self.dayLabel.text = String(day)
            //TODO: remove check for the each note!!! About 30 requests and each time table reloads -- it's too hard!!
            DataManager.instance.getNote(by: date, completion: { note, error in
                self.hasNote = note != nil
            })
        }
    }
}
