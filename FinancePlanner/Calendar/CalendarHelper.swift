//
//  CalendarHelper.swift
//  FinancePlanner
//
//  Created by Anastasiia on 09.12.2022.
//

import Foundation

class CalendarHelper {
    let calendar = Calendar.current
    
    func days(for date: Date) -> [Int] {
        let daysInMonth = daysInMonth(date: date)
        return Array(1...daysInMonth)
    }
    
    func months() -> [String] {
        return calendar.monthSymbols
    }
    
//    func getMonthIndex(by name: String) -> Int {
//        for i in 0...calendar.monthSymbols.count {
//            if calendar.monthSymbols[i] == name {
//                return i
//            }
//        }
//        return 0
//    }
    
    func years() -> [Int] {
        let minYear = 1999
        let maxYear = 2030
        return Array(minYear...maxYear)
    }
    
    func plusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func dateString(date: Date, long: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = long ? "dd LLL, yyyy" : "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
    
    func monthString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    func monthAndYearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL, yyyy"
        return dateFormatter.string(from: date)
    }
    
    func yearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func daysInMonth(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func dayOfMonth(date: Date) -> Int {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func weekDay(date: Date) -> Int {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
    
    func isDate(date: Date, equalTo date2: Date) -> Bool {
        return calendar.isDate(date, equalTo: date2, toGranularity: .day)
    }
    
    func dateByDay(day: Int, date: Date) -> Date {
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        dateComponents.day = day
        return calendar.date(from: dateComponents)!
    }
 
    func dateByComponents(day: Int = 1, month: Int = 1, year: Int, date: Date) -> Date {
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        return calendar.date(from: dateComponents)!
    }
    
    func componentsByDate(_ date: Date) -> (Int, Int, Int) {
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return (dateComponents.day!, dateComponents.month!, dateComponents.year!)
    }
}
