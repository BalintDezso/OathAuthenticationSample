//
//  AccountViewController.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    var authenticationService: AuthenticationService!
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }
    
    private func updateUI() {
        
        if let user = authenticationService.currentUser {
            
            accountLabel.text = "Welcome \(user)"
            loginButton.setTitle("Logout", for: .normal)
        } else {
            
            accountLabel.text = "Please login"
            loginButton.setTitle("Login", for: .normal)
        }
    }
    
    @IBAction private func didTapLogin(_ sender: UIButton) {
        
        if authenticationService.currentUser != nil {
            
            authenticationService.logout()
            updateUI()
        } else {
            authenticationService.authenticate { error in
                
                if let error = error {
                    print("Authentication failed with error: \(error)")
                    return
                }
                self.updateUI()
            }
        }
    }
}
