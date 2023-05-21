//
//  String+Extensions.swift
//  FinancePlanner
//
//  Created by Anastasiia on 21.05.2023.
//

import UIKit

extension String {
    func getDoubleFromText() -> Double {
        var amount: Double = 0
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        let grade = formatter.number(from: self)
        if let doubleGrade = grade?.doubleValue {
            amount = doubleGrade
        } else {
            amount = Double(self) ?? 0
        }
        return amount
    }
}
