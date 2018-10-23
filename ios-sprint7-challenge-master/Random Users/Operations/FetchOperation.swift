//
//  FetchOperation.swift
//  Random Users
//
//  Created by Jonathan T. Miles on 10/22/18.
//  Copyright © 2018 Erica Sadun. All rights reserved.
//

import Foundation
import UIKit

class FetchOperation: ConcurrentOperation {
    
    init(randomUser: RandomUser, session: URLSession = URLSession.shared) {
        self.randomUser = randomUser
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        let url = randomUser.picture.thumbnail
        
        let task = session.dataTask(with: url) { (data, _, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.randomUser): \(error)")
                return
            }
            guard let data = data else { return }
            self.image = UIImage(data: data)
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: - Properties
    
    let randomUser: RandomUser
    private let session: URLSession
    private(set) var image: UIImage?
    private var dataTask: URLSessionDataTask?
    
}
