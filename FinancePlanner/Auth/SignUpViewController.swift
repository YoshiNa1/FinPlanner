//
//  SignUpViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.02.2023.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var formBackground: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(confirmPasswordTextFieldDidChange(_:)), for: .editingChanged)
        
        addKeyboardRecognizer()
        
        formBackground.layer.cornerRadius = 16
        continueButton.layer.cornerRadius = 8
    }
    
    
    @IBAction func continueClicked(_ sender: Any) {
        let password = passwordField.text ?? ""
        let confirmPassword = confirmPasswordField.text ?? ""
        if password != confirmPassword {
            self.showAlert(message: "The passwords don't match")
            return
        }
        
        let user = User(email: PreferencesStorage.shared.email, password: password)
        DataManager.instance.registration(user: user) { user, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.changeRootViewController(with: "setupProfileVC")
        }
    }
    
    @IBAction func backClicked(_ sender: Any) {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.changeRootViewController(with: "loginVC")
    }
    
    
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        validatePassword(textField, confirmPasswordField)
    }
    @objc func confirmPasswordTextFieldDidChange(_ textField: UITextField) {
        validatePassword(textField, passwordField)
    }
    
    func validatePassword(_ textFieldFirst: UITextField, _ textFieldSecond: UITextField) {
        let firstFieldText = textFieldFirst.text ?? ""
        if !firstFieldText.isEmpty &&
            firstFieldText == textFieldSecond.text &&
            DataManager.instance.validatePassword(firstFieldText) {
            self.continueButton.isEnabled = true
        } else {
            self.continueButton.isEnabled = false
        }
    }
}
