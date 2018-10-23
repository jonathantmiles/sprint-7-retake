//
//  RandomUserDetailViewController.swift
//  Random Users
//
//  Created by Jonathan T. Miles on 10/22/18.
//  Copyright © 2018 Erica Sadun. All rights reserved.
//

import UIKit

class RandomUserDetailViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchImage()
    }
    
    private func fetchImage() {
        guard let randomUser = randomUser else { return }
        let url = randomUser.picture.large
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error loading Big Picture: \(error)")
                return
            }
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func updateViews() {
        guard let randomUser = randomUser else { return }
        let name = "\(randomUser.name.title) + \(randomUser.name.first) + \(randomUser.name.last)"
        nameLabel.text = name
        phoneNumber.text = randomUser.phone
        emailAddressLabel.text = randomUser.email
    }
    
    var randomUser: RandomUser?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    
}
