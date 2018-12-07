//
//  Network.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import Foundation
import Alamofire

class Network {
    
    weak var delegate: AuthenticationDelegate? {
        didSet {
            retrier.delegate = delegate
            adapter.delegate = delegate
        }
    }
    
    private let session: SessionManager
    private let retrier: NetworkRequestRetrier
    private let adapter: NetworkRequestAdapter
    
    required init() {
        
        let configuration = URLSessionConfiguration.default
        session = SessionManager(configuration: configuration)
        
        retrier = NetworkRequestRetrier()
        adapter = NetworkRequestAdapter()
        
        session.retrier = retrier
        session.adapter = adapter
    }
    
    func send(request: URLRequest, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        
        session.request(request).validate().response { response in
            
            if let error = response.error {
                completion(nil, error)
                return
            } else {
                completion(response.data, nil)
            }
        }
    }
}
