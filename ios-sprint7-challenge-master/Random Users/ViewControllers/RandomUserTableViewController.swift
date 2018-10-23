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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RandomCell", for: indexPath) as? RandomUserTableViewCell ?? RandomUserTableViewCell()
        
        loadData(forCell: cell, forRowAt: indexPath)
        
        return cell
    }
    
    // MARK: - Private
    
    private func loadData(forCell cell: RandomUserTableViewCell, forRowAt indexPath: IndexPath) {
        let randomUser = fetchController.randomUsers[indexPath.row]
        
        let fetchOp = FetchOperation(randomUser: randomUser)
        
        let cacheOp = BlockOperation {
            if let imageData = fetchOp.imageData {
                self.cache.cache(value: imageData, for: randomUser.email)
            }
        }
        
        let completionOp = BlockOperation {
            NSLog("Completed")
            defer { self.operations.removeValue(forKey: randomUser.email) }
            
            if let currentIndexPath = self.tableView.indexPath(for: cell),
                currentIndexPath != indexPath {
                return
            }
            
            if let imageData = fetchOp.imageData,
                let imageView = cell.imageView {
                imageView.image = UIImage(data: imageData)
                
                let name = "\(randomUser.name.title) + \(randomUser.name.first) + \(randomUser.name.last)"
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
        destVC.randomUser = fetchController.randomUsers[indexPath.row]
    }
    
    // MARK: - Properties
    
    let fetchController = FetchController()
    
    private let photoFetchQueue = OperationQueue()
    
    private var operations = [String : Operation]()
    
    private let cache = Cache<String, Data>()

}
