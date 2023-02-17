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
    var settingsViewController: SettingsViewController?
    var tabbarViewController: TabbarViewController?
    
    public func setupHomePage(_ homeVC: HomeViewController) {
        self.homeViewController = homeVC
    }
    public func setupSettingsPage(_ settingsVC: SettingsViewController) {
        self.settingsViewController = settingsVC
    }
    public func setupTabbarVC(_ tabbarVC: TabbarViewController) {
        self.tabbarViewController = tabbarVC
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
