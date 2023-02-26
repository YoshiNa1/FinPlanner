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
        PreferencesStorage.shared.email = email
        
        var identifier = "signUpVC"
        if let user = DataManager.instance.user, user.email == email {
            identifier = "signInVC"
        }
            
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.changeRootViewController(with: identifier)
    }
    
}
