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
    
    public func setupHomePage(_ homeVC: HomeViewController) {
        self.homeViewController = homeVC
    }
    
}
