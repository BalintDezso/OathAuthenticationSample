//
//  LoginViewController.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var onLogin: ((String?, String?, Bool) -> Void)?

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageLabel.text = ""
    }
    
    func showMessage(_ message: String) {
        messageLabel.text = message
    }
    
    @IBAction private func loginTapped(_ sender: UIButton) {
        
        if let password = passwordTextField.text,
            !password.isEmpty,
            let email = emailTextField.text,
            !email.isEmpty {
            
            onLogin?(email, password, false)
        } else {
            
            showMessage("We need an email and a password to log you in.")
        }
        
    }
    
    @IBAction private func cancelTapped(_ sender: UIButton) {
        
        onLogin?(nil, nil, true)
    }
}
