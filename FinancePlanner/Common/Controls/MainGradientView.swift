//
//  MainGradientView.swift
//  FinancePlanner
//
//  Created by Anastasiia on 07.01.2023.
//

import UIKit

class MainGradientView : UIView {
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor(named: "MainGradient_StartColor")?.cgColor ?? UIColor.white.cgColor,
            UIColor(named: "MainGradient_EndColor")?.cgColor ?? UIColor.white.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        layer.addSublayer(gradient)
        return gradient
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = bounds.width / 2.0
    }
}
