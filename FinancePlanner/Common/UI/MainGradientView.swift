//
//  MainGradientView.swift
//  FinancePlanner
//
//  Created by Anastasiia on 07.01.2023.
//

import UIKit

@IBDesignable class MainGradientView : UIView {
    @IBInspectable var radius: CGFloat = 0.0
    
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
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = (radius == 0.0) ? bounds.width / 2.0 : radius
    }
}
