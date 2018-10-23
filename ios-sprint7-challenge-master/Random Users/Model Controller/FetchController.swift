//
//  FetchController.swift
//  Random Users
//
//  Created by Jonathan T. Miles on 10/22/18.
//  Copyright © 2018 Erica Sadun. All rights reserved.
//

import Foundation

class FetchController {
    
    init() {
        fetchRandomUsers()
    }
    
    func fetchRandomUsers() {
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching RandomUsers: \(error)")
                return
            }
            guard let data = data else {
                NSLog("Error with data returned from fetch: \(error)")
                return
            }
            
            do {
                let resultsAndInfo = try JSONDecoder().decode([String: [String: RandomUser]].self, from: data)
                if let results = resultsAndInfo["object"] {
                    self.randomUsers = Array(results.values)
                }
            } catch {
                NSLog("Error decoding JSON Data: \(error)")
                return
            }
        }
        
    }
    
    var randomUsers: [RandomUser] = []
    
    private let url = URL(string: "https://randomuser.me/api/?format=json&inc=name,email,phone,picture&results=1000")!
}
