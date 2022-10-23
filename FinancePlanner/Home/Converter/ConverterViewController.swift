//
//  ConverterViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import UIKit

class ConverterViewController: UIViewController {
    @IBOutlet weak var firstField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstField.addTarget(self, action: #selector(firstTextFieldDidChange(_:)), for: .editingChanged)
        secondField.addTarget(self, action: #selector(secondTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func firstTextFieldDidChange(_ textField: UITextField) {
        self.secondField.text = textField.text // HARDCODE
    }
    @objc func secondTextFieldDidChange(_ textField: UITextField) {
        self.firstField.text = textField.text //HARDCODE
    }
}
