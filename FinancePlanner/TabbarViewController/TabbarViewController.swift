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
    var thumbView: MainGradientView!
    let thumbViewWidth: Int = 70
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupThumbView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIManager.shared.setupTabbarVC(self)
        
        tabBar.backgroundColor = UIColor(named: "MainBackgroundColor")
        tabBar.layer.cornerRadius = 16
        
        self.delegate = self
    }
    
    func setupThumbView() {
        thumbView = MainGradientView(frame: CGRect(x: 172, y: 19, width: thumbViewWidth, height: thumbViewWidth)) // HARDCODE: 172 = x for 2nd item
        thumbView.backgroundColor = .clear
        tabBar.insertSubview(thumbView, at: 0)
        
        self.selectedIndex = 2 // HOME PAGE
    }
    
    func didSelectItem(at index: Int, duration: CGFloat = 0.3) {
        self.selectedIndex = index
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let buttons = self.tabBar.subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }
            UIView.animate(withDuration: duration) {
                self.thumbView.frame.origin.x = buttons[index].frame.midX - CGFloat(self.thumbViewWidth / 2)
            }
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
