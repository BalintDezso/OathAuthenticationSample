//
//  TokenRefreshReponse.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation

struct TokenRefreshResponse: Decodable {
    
    let authorizationToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        
        case authorizationToken = "id_token"
        case refreshToken = "refresh_token"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        authorizationToken = try container.decode(String.self, forKey: .authorizationToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}
