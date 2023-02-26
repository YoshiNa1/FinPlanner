//
//  SignInViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.02.2023.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var formBackground: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        formBackground.layer.cornerRadius = 16
        continueButton.layer.cornerRadius = 8
    }
    
    
    @IBAction func continueClicked(_ sender: Any) {
        let password = passwordField.text ?? ""
        PreferencesStorage.shared.password = password
        
        if DataManager.instance.user.password == password {
            var identifier = "mainTabbarVC"
            if PreferencesStorage.shared.currencies.isEmpty {
                identifier = "setupProfileVC"
            }
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.changeRootViewController(with: identifier)
        } else {
            let alert = UIAlertController(title: "Error", message: "Invalid Password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @IBAction func forgotPasswordClicked(_ sender: Any) {
        // DO SOMETHING TO RECOVERY PASSWORD
    }
    
    @IBAction func backClicked(_ sender: Any) {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.changeRootViewController(with: "loginVC")
    }
}
