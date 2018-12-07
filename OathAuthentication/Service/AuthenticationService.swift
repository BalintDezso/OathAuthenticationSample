//
//  AuthenticationService.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation

enum AuthenticationError: Error {
    
    case invalidRefreshTokenURL
    case invalidAuthenticationURL
    case noDelegateSetError
    case userCanceledError
    case emptyCredentialsError
    case missingDataError
}

class AuthenticationService {
    
    // Delegates the credential collection to another object
    weak var delegate: AuthenticationServiceDelegate?

    // Is set only after we preform a successful authentication
    fileprivate (set) var currentUser: String?
    
    private let network: Network
    
    // Needed to build Firebase authentication request
    private let apiKey: String
    
    // Used to store the tokens we receive from an authentication request
    private var refreshToken: String?
    private var authorizationToken: String?
    
    // Used when we send credentials and receive an authorization token on the response
    private let authenticationBase = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword"
    
    // Used when we send the refresh token and receive an authorization token on the response
    private let tokenrefreshBase = "https://securetoken.googleapis.com/v1/token"
    
    init(network: Network, apiKey: String) {
        
        self.network = network
        self.apiKey = apiKey
    }
    
    func authenticate(completion: @escaping (Error?) -> Void) {
        
        // If we have a refresh token, use it to get a new token,
        // otherwise preform a clean authentication by getting credentials
        // from the user
        if let refreshToken = self.refreshToken {
            
            refreshAuthorizationToken(withRefreshToken: refreshToken) { (error) in

                completion(error)
            }
            
        } else {
            
            cleanAuthentication(completion: completion)
        }
    }
    
    func logout() {
        
        currentUser = nil
        refreshToken = nil
        authorizationToken = nil
    }
    
    private func refreshAuthorizationToken(withRefreshToken refreshToken: String,
                                           completion: @escaping (Error?) -> Void) {
        
        // Build the refresh token url
        guard let refreshTokenUrl = URL(string: "\(tokenrefreshBase)?\(apiKey)") else {
            
            completion(AuthenticationError.invalidRefreshTokenURL)
            return
        }
        
        // Add the required body, consult the documentation for Firebase to understand more details
        // https://firebase.google.com/docs/reference/rest/auth/
        let body = "grant_type=refresh_token&refresh_token=\(refreshToken)"
        let bodyData = body.data(using: .ascii, allowLossyConversion: true)
        
        var request = URLRequest(url: refreshTokenUrl)
        request.httpMethod = "POST"
        
        // Header required by Firebase
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
            
        self.network.send(request: request, completion: { (data, error) in
                
            if let error = error {
                
                completion(error)
                return
            }
                
            guard let data = data else {
                
                completion(AuthenticationError.missingDataError)
                return
            }
                
            let jsonDecoder = JSONDecoder()
            
            do {
                
                // Decode the response
                let tokenRefreshResponse = try jsonDecoder.decode(TokenRefreshResponse.self, from: data)
                
                // Save the refresh and authorization token from the response and call the
                // completion handler with no error
                self.authorizationToken = tokenRefreshResponse.authorizationToken
                self.refreshToken = tokenRefreshResponse.refreshToken
                
                completion(nil)
            } catch {
                
                completion(error)
            }
        })
    }
    
    private func cleanAuthentication(completion: @escaping (Error?) -> Void) {
        
        guard let delegate = delegate else {
            
            completion(AuthenticationError.noDelegateSetError)
            return
        }
        
        // Call the delegate to get credentials, the delegate should be a ViewController
        // as it would need to present some UI to collect the required info from the user
        delegate.getCredentials { credentialRequest in
            
            // First check if the user canceled the credential request before we continue
            guard !credentialRequest.isCanceled else {
                
                completion(AuthenticationError.userCanceledError)
                return
            }
            
            // Next unwrap the username and password as they are both required to authenticate
            guard let username = credentialRequest.username,
                let password = credentialRequest.password else {
                    
                completion(AuthenticationError.emptyCredentialsError)
                return
            }
            
            // Authenticate with username and password
            self.authenticate(withUsername: username,
                              password: password,
                              completion: { (error) in
                
                // The credenetial request has it own completion handler
                // in order for the delegate to know when it can dismiss
                // any UI it has presented to collect the credentials
                                
                credentialRequest.completion?(error)
                    
                // Here we are careful to only call the completion handler of the method
                // only when we get a successful authentication in order to not fail the
                // whole chain of authentication on the first error. Think about the case
                // where we entered a bad password, we return this error to the delegate
                // but we put the authentication flow on hold until the user tries again
                if error == nil {
                    completion(nil)
                }
            })
        }
    }
    
    private func authenticate(withUsername username: String,
                              password: String,
                              completion: @escaping (Error?) -> Void) {
        
        // Build the authentication url
        guard let authenticationUrl = URL(string: "\(authenticationBase)?key=\(apiKey)") else {
            
            completion(AuthenticationError.invalidAuthenticationURL)
            return
        }
        
        do {
            
            // Build the body, for more details check the Firebase documentation
            // https://firebase.google.com/docs/reference/rest/auth/
            let authDictionary: [String : Any] = ["email": username,
                                                  "password": password,
                                                  "returnSecureToken": true]
            
            let jsonData = try JSONSerialization.data(withJSONObject: authDictionary,
                                                      options: .prettyPrinted)
            
            var request = URLRequest(url: authenticationUrl)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            self.network.send(request: request, completion: { (data, error) in
                
                if let error = error {
                    
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    
                    completion(AuthenticationError.missingDataError)
                    return
                }
                
                let jsonDecoder = JSONDecoder()
                
                do {
                    
                    // Decode the authentication response
                    let authenticationResponse = try jsonDecoder.decode(AuthenticationResponse.self, from: data)
                    
                    // Save the authorization and refresh token along with the current user,
                    // important to note that the current user info is only received on an
                    // authentication request and not on a refresh token request
                    self.authorizationToken = authenticationResponse.authorizationToken
                    self.refreshToken = authenticationResponse.refreshToken
                    self.currentUser = authenticationResponse.email
                    
                    completion(nil)
                    
                } catch {
                    
                    completion(error)
                }
            })
        }
        catch {
            
            completion(error)
        }
    }
}

extension AuthenticationService: AuthenticationDelegate {
    
    func authenticate(request: URLRequest, completion: @escaping (Bool) -> Void) {
        
        print("Authenticating request: \(request).")
        
        // When the network calls this method we need to call out authenticate method
        // which will either refresh the authorization token using the refresh token
        // or call it's own delegate to get credentials from the user and prefrom a
        // clean authentication
        authenticate { error in
            
            if let error = error {
                
                print("Authentication failed for request: \(request) with error: \(error)")
            }
            
            completion(error == nil)
        }
    }
    
    func authorize(request: URLRequest) -> URLRequest {
        
        // Make sure not to authorize the authentication and token refresh urls
        guard let urlString = request.url?.absoluteString,
            !urlString.contains(authenticationBase),
            !urlString.contains(tokenrefreshBase),
            let authorizationToken = authorizationToken,
            var urlComponents = URLComponents(string: urlString) else {
                
            return request
        }
        
        // As per firebase, we authenticate request by adding the following url parameter
        let queryItem = URLQueryItem(name: "auth", value: authorizationToken)
        
        // Make sure not to lose any existing parameters
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(queryItem)
        
        urlComponents.queryItems = queryItems
        
        var request = request
        request.url = urlComponents.url
        
        return request
    }
}
