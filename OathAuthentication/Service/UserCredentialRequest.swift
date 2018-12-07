//
//  UserCredentialRequest.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation

struct UserCredentialRequest {
    
    var username: String?
    var password: String?
    var isCanceled: Bool = false
    var completion: ((Error?) -> Void)?
}
