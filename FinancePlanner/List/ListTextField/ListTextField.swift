//
//  ListTextField.swift
//  FinancePlanner
//
//  Created by Anastasiia on 03.09.2022.
//

import UIKit

protocol ListTextFieldDelegate {
    func textFieldDidReturn(_ textField: UITextField)
    func textFieldDidDelete(_ textField: UITextField)
    func textFieldDidChange(_ textField: UITextField)
}

class ListTextField: UITextField, UITextFieldDelegate {
    var listDelegate: ListTextFieldDelegate?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.delegate = self
    }
    
    override func deleteBackward() {
        if text?.isEmpty == true {
            listDelegate?.textFieldDidDelete(self)
        }
        super.deleteBackward()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        listDelegate?.textFieldDidReturn(self)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        listDelegate?.textFieldDidChange(self)
    }
    

//    override var canResignFirstResponder: Bool {
//        return false
//    }
}
