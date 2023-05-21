//
//  UITextField+Extensions.swift
//  FinancePlanner
//
//  Created by Anastasiia on 21.05.2023.
//

import UIKit

extension UITextField {
    func getDoubleFromField() -> Double {
        var amount: Double = 0
        if let amountText = self.text {
            amount = amountText.getDoubleFromText()
        }
        return amount
    }
}
