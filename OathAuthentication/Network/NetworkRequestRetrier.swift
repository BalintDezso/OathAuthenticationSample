//
//  AuthenticationRequestRetrier.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation
import Alamofire

class NetworkRequestRetrier: RequestRetrier {
    
    weak var delegate: AuthenticationDelegate?
    
    private var isAuthenticating: Bool
    private var pendingRequests: [RequestRetryCompletion]
    
    init() {
        
        isAuthenticating = false
        pendingRequests = [RequestRetryCompletion]()
    }
    
    func should(_ manager: SessionManager,
                retry request: Request,
                with error: Error,
                completion: @escaping RequestRetryCompletion) {

        // Check to see if the request failed due to an authorization error
        // and unwrap the request and delegate before continuing
        guard let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            let urlRequest = request.request,
            let delegate = delegate else {
                
                return completion(false, 0)
        }
    
        // Store the retry completion in an array
        pendingRequests.append(completion)
        
        if isAuthenticating {
            // If an authentication is already in progress we should not continue
            // the request will be retried once the authentication is completed
            // by going through the array of stored retry completions
            return
        } else {
            isAuthenticating = true
        }
        
        delegate.authenticate(request: urlRequest) { success in
            
            // Go through each stored retry completion and retry or not the request
            self.pendingRequests.forEach { $0(success, 0) }
            // Clear the stored pending requests
            self.pendingRequests.removeAll()
            // Reset the authenticating flag
            self.isAuthenticating = false
        }
    }
}
