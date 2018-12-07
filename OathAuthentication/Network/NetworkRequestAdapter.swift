//
//  AlomfireRequestAdapter.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation
import Alamofire

class NetworkRequestAdapter: RequestAdapter {
    
    weak var delegate: AuthenticationDelegate?
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        return delegate?.authorize(request: urlRequest) ?? urlRequest
    }
}
