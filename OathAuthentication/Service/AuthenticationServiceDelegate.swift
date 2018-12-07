//
//  AuthenticationServiceDelegate.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation

protocol AuthenticationServiceDelegate: class {
    
    func getCredentials(completion: @escaping (UserCredentialRequest) -> Void)
}
