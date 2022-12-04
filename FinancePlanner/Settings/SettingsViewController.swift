//
//  SettingsViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogoutView()
    }
    
    func setupLogoutView() {
        logoutView.backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor(named: "MainGradient_StartColor")?.cgColor ?? UIColor.white.cgColor,
            UIColor(named: "MainGradient_EndColor")?.cgColor ?? UIColor.white.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = logoutView.bounds
        gradient.cornerRadius = 35
        logoutView.layer.insertSublayer(gradient, at: 0)
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
    }
    
}
