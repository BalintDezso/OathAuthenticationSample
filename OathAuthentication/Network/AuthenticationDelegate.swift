//
//  AuthenticationDelegate.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation

protocol AuthenticationDelegate: class {
    
    func authenticate(request: URLRequest,
                      completion: @escaping (Bool) -> Void)
    
    func authorize(request: URLRequest) -> URLRequest
}
