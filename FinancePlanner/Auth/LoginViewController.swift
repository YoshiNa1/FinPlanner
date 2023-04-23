//
//  LoginViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.02.2023.
//

import UIKit

let oath2key = "1087220546550-vqao0uql3qit5dea4bp0e1jfflco7iuh.apps.googleusercontent.com"

class LoginViewController: UIViewController {
    @IBOutlet weak var formBackground: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var socialButtonsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardRecognizer()
        
        formBackground.layer.cornerRadius = 16
        continueButton.layer.cornerRadius = 8
    }
    
    
    @IBAction func continueClicked(_ sender: Any) {
        if Connectivity.isConnected() {
            let email = emailField.text ?? ""
            DataManager.instance.isUserExist(email) { exists, error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                PreferencesStorage.shared.email = email
                let identifier = exists ? "signInVC" : "signUpVC"
                    
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                sceneDelegate?.changeRootViewController(with: identifier)
            }
        } else {
            showAlert(message: "No internet connection.")
        }
        
    }
    
}
