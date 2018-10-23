//
//  RandomUserTableViewController.swift
//  Random Users
//
//  Created by Jonathan T. Miles on 10/22/18.
//  Copyright © 2018 Erica Sadun. All rights reserved.
//

import UIKit

class RandomUserTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRandomUsers()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return randomUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RandomCell", for: indexPath) as? RandomUserTableViewCell ?? RandomUserTableViewCell()
        
        loadData(forCell: cell, forRowAt: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if randomUsers.count > 0 {
            let randomUser = randomUsers[indexPath.row]
            operations[randomUser.email]?.cancel()
        } else {
            for (_, operation) in operations {
                operation.cancel()
            }
        }
    }
    
    // MARK: - Private
    
    func fetchRandomUsers() {
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching RandomUsers: \(error)")
                return
            }
            guard let data = data else {
                NSLog("Error with data returned from fetch: \(error)")
                return
            }
            
            do {
                let resultsAndInfo = try JSONDecoder().decode(Results.self, from: data)
                let results = resultsAndInfo.results
                self.randomUsers = results
            } catch {
                NSLog("Error decoding JSON Data: \(error)")
                return
            }
        }.resume()
        
    }
    
    
    
    private func loadData(forCell cell: RandomUserTableViewCell, forRowAt indexPath: IndexPath) {
        let randomUser = randomUsers[indexPath.row]
        
        if let cachedImage = cache.value(for: randomUser.email) {
            cell.imageView?.image = cachedImage
            return
        }
        
        let fetchOp = FetchOperation(randomUser: randomUser)
        
        let cacheOp = BlockOperation {
            if let image = fetchOp.image {
                self.cache.cache(value: image, for: randomUser.email)
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: randomUser.email) }
            
            if let currentIndexPath = self.tableView.indexPath(for: cell),
                currentIndexPath != indexPath {
                return
            }
            
            if let image = fetchOp.image,
                let imageView = cell.imageView {
                imageView.image = image
                
                let name = "\(randomUser.name.title). " + "\(randomUser.name.first) " + "\(randomUser.name.last)"
                cell.nameLabel.text = name
            }
        }
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        photoFetchQueue.addOperation(fetchOp)
        photoFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[randomUser.email] = fetchOp
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! RandomUserDetailViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        destVC.randomUser = randomUsers[indexPath.row]
    }
    
    // MARK: - Properties
    
    var randomUsers = [RandomUser]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let url = URL(string: "https://randomuser.me/api/?format=json&inc=name,email,phone,picture&results=1000")!
    
    private let photoFetchQueue = OperationQueue()
    
    private var operations = [String : Operation]()
    
    private let cache = Cache<String, UIImage>()

}
