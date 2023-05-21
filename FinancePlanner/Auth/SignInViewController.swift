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
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            PreferencesStorage.shared.accessToken = user?.accessToken ?? ""
            
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            DataManager.instance.getProfile(completion: { profile, _ in
                if let profile = profile {
                    if PreferencesStorage.shared.currencies.isEmpty { //TODO: ПЕРЕПРОВЕРИТЬ УСЛОВИЕ, ЛОГИЧНО ЛИ ЭТО???
                        let currency = Currency(name: profile.currency, isDefault: true)
                        PreferencesStorage.shared.currencies.append(currency)
                        sceneDelegate?.changeRootViewController(with: "setupProfileVC")
                    } else {
                        DataManager.instance.syncAllData { error in
                            if let error = error {
                                print("Sync data error: \(error.localizedDescription)")
                            }
                            sceneDelegate?.changeRootViewController(with: "mainTabbarVC")
                        }
                    }
                } else {
                    sceneDelegate?.changeRootViewController(with: "setupProfileVC")
                }
            })
            
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
