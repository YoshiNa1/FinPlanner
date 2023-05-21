//
//  UIViewController+Extensions.swift
//  FinancePlanner
//
//  Created by Anastasiia on 22.04.2023.
//

import UIKit
import MBProgressHUD

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

extension UIViewController {
    func processing(_ processing: Bool) {
        DispatchQueue.main.async {
            if processing {
                let hud = MBProgressHUD.showAdded(to: self.view,
                                                  animated: true)
                hud.isUserInteractionEnabled = false
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
}

