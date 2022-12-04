//
//  TabbarViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 03.12.2022.
//

import UIKit

class CustomTabbar : UITabBar {
    @IBInspectable var height: CGFloat = 0.0
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        if height > 0.0 {
            sizeThatFits.height = height
        }
        return sizeThatFits
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttons = subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }
        buttons.enumerated().forEach({$0.element.frame.size.height = 108})
    }
}

class TabbarViewController: UITabBarController {
    var thumbView: ThumbView!
    let thumbViewWidth: Int = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupThumbView()
        
        tabBar.backgroundColor = UIColor(named: "MainBackgroundColor")
        tabBar.layer.cornerRadius = 16
        
        self.delegate = self
    }
    
    func setupThumbView() {
        thumbView = ThumbView(frame: CGRect(x: 0, y: 19, width: thumbViewWidth, height: thumbViewWidth))
        thumbView.backgroundColor = .clear
        self.tabBar.insertSubview(thumbView, at: 0)
        
        DispatchQueue.main.async {
            self.selectedIndex = 2
            self.didSelectItem(at: self.selectedIndex, duration: 0.0)
        }
    }
    
    func didSelectItem(at index: Int, duration: CGFloat = 0.3) {
        let buttons = tabBar.subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }
        UIView.animate(withDuration: duration) {
            self.thumbView.frame.origin.x = buttons[index].frame.midX - CGFloat(self.thumbViewWidth / 2)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        didSelectItem(at: index)
    }
    
}

extension TabbarViewController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else { return false }
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }
        return true
    }
}

class ThumbView : UIView {
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
