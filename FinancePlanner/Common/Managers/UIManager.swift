//
//  UIManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import Foundation
import UIKit

class UIManager {
    static let shared = UIManager()
    
    var homeViewController: HomeViewController?
    var listViewController: ListViewController?
    var calendarViewController: CalendarViewController?
    var statisticsViewController: StatisticsViewController?
    var settingsViewController: SettingsViewController?
    var tabbarViewController: TabbarViewController?
    
    public func setupHomePage(_ homeVC: HomeViewController) {
        self.homeViewController = homeVC
    }
    public func setupListPage(_ listVC: ListViewController) {
        self.listViewController = listVC
    }
    public func setupCalendarPage(_ calendarVC: CalendarViewController) {
        self.calendarViewController = calendarVC
    }
    public func setupStatisticsPage(_ statisticsVC: StatisticsViewController) {
        self.statisticsViewController = statisticsVC
    }
    public func setupSettingsPage(_ settingsVC: SettingsViewController) {
        self.settingsViewController = settingsVC
    }
    
    public func setupTabbarVC(_ tabbarVC: TabbarViewController) {
        self.tabbarViewController = tabbarVC
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadUI),
                                               name: .syncStatusChanged,
                                               object: nil)
    }
    
    @objc func reloadUI() {
        self.homeViewController?.updateUI()
        self.listViewController?.updateUI()
        self.calendarViewController?.updateUI()
        self.statisticsViewController?.updateUI()
        self.settingsViewController?.updateUI()
    }
    
    public func navigateToHomePage(with date: Date) {
        DispatchQueue.main.async {
            self.tabbarViewController?.selectedIndex = 2
            self.tabbarViewController?.didSelectItem(at: 2)
        }
        homeViewController?.date = date
    }
    
    public func getHomePageDate() -> Date {
        return self.homeViewController?.date ?? Date()
    }
    
    public func format(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let formattedString = formatter.string(from: NSNumber(value: amount))
        return formattedString ?? ""
    }
}

extension UIViewController {
    func addKeyboardRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
