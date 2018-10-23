//
//  RandomUser.swift
//  Random Users
//
//  Created by Jonathan T. Miles on 10/22/18.
//  Copyright © 2018 Erica Sadun. All rights reserved.
//

import Foundation

struct RandomUser: Codable {
    let name: Name
    let email: String
    let phone: String
    let picture: Picture
    
    struct Name: Codable {
        let title: String
        let first: String
        let last: String
    }
    
    struct Picture: Codable {
        let large: URL
        let medium: URL
        let thumbnail: URL
    }
}
