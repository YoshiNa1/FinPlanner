//
//  UIViewController+Extensions.swift
//  FinancePlanner
//
//  Created by Anastasiia on 22.04.2023.
//

import UIKit

extension UIViewController {
    func showAlert(with title: String = "", message: String, actions: [String] = [String]()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if actions.isEmpty {
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        } else {
            for action in actions {
                alert.addAction(UIAlertAction(title: action, style: .destructive, handler: nil))
            }
        }
        present(alert, animated: true)
    }
}
