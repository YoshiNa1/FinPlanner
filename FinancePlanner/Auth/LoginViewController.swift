//
//  LoginViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.02.2023.
//

import UIKit

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
        let email = emailField.text ?? ""
        DataManager.instance.isUserExist(email) { exists, error in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                self.present(alert, animated: true)
                return
            }
            PreferencesStorage.shared.email = email
            let identifier = exists ? "signInVC" : "signUpVC"
                
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.changeRootViewController(with: identifier)
        }
    }
    
}
