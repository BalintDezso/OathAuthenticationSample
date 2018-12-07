//
//  ViewController.swift
//  OathAuthentication
//
//  Created by Balint Dezso on 11/23/18.
//  Copyright © 2018 Balint Dezso. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var network: Network!
    
    @IBOutlet private weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        
        resultLabel.text = ""
        super.viewDidLoad()
    }
    
    @IBAction private func testDataTapped(_ sender: UIButton) {
        
        resultLabel.text = ""
        
        let testDataUrl = URL(string: "https://authenticationshowcase.firebaseio.com/test.json")!
        
        network.send(request: URLRequest(url: testDataUrl)) { data, error in
            
            if let error = error {
                
                print("Failed to get test data with error: \(error)")
                self.resultLabel.text = "There was an error, please check the logs."
                return
            }
            
            self.resultLabel.text = "Test data fetch successfully."
        }
    }
}

