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
        let user = User(email: PreferencesStorage.shared.email, password: password)
        DataManager.instance.login(user: user) { user, error in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                self.present(alert, animated: true)
                return
            }
            PreferencesStorage.shared.accessToken = user?.accessToken ?? ""
            
            var identifier = "mainTabbarVC"
            DataManager.instance.getProfile(completion: { profile, _ in
                if let profile = profile, PreferencesStorage.shared.currencies.isEmpty {
                    let currency = Currency(name: profile.currency, isDefault: true)
                    PreferencesStorage.shared.currencies.append(currency)
                    identifier = "setupProfileVC"
                }
            })
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.changeRootViewController(with: identifier)
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
