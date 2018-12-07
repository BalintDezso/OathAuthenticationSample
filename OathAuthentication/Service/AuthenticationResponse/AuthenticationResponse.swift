//
//  AuthenticationResponse.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation

struct AuthenticationResponse: Decodable {
    
    let id: String
    let email: String
    let authorizationToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        
        case id = "localId"
        case email
        case authorizationToken = "idToken"
        case refreshToken
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        authorizationToken = try container.decode(String.self, forKey: .authorizationToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}
