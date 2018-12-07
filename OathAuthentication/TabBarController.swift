//
//  TabBarController.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    private var network: Network!
    private var authenticationService: AuthenticationService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        network = Network()
        authenticationService = AuthenticationService(network: network,
                                                      apiKey: "YOUR_API_KEY")
        network.delegate = authenticationService
        authenticationService.delegate = self
        
        if let testDataVC = viewControllers?.first as? ViewController {
            
            testDataVC.network = network
        }
        
        if let accountVC = viewControllers?[1] as? AccountViewController {
            
            accountVC.authenticationService = authenticationService
        }
    }
}

extension TabBarController: AuthenticationServiceDelegate {
    
    func getCredentials(completion: @escaping (UserCredentialRequest) -> Void) {
        
        DispatchQueue.main.async {
            
            // Present the login view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard  let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController else {
                
                fatalError("Login view controller could not be loaded.")
            }
            
            // Listen to when the user taps the login button
            loginVC.onLogin = { (email, password, userCanceled) in
                
                var credentialRequest = UserCredentialRequest()
                credentialRequest.username = email
                credentialRequest.password = password
                credentialRequest.isCanceled = userCanceled
                
                // If the user canceled we should dismiss the login
                if userCanceled {
                    
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    
                    // If the user did not cancel than we subscribe
                    // to the credential request outcome and display any errors
                    // or dismiss the login view if there was no error
                    credentialRequest.completion = { error in
                        
                        if let error = error {
                            
                            print("Authentication with credentials: \(credentialRequest) failed with error: \(error)")
                            loginVC.showMessage("Something went wrong, try again!")
                        } else {
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
                completion(credentialRequest)
            }
            
            self.present(loginVC,
                         animated: true,
                         completion: nil)
        }
    }
}
