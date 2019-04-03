//
//  ResturantTableViewController.swift
//  Vibes
//
//  Copyright © 2019 Abdul Jabbar. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase
class ResturantTableViewController: UITableViewController , UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filtereRes = resturantDetails
        } else {
            // Filter the results
            filtereRes = resturantDetails.filter { $0.resturantName.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        
        self.tableView.reloadData()
    }
    
    static var sh = ResturantTableViewController()
    var resturantDetails:[Details] = []
    // from
    var filtereRes = [Details]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filtereRes = resturantDetails
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filtereRes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! resturantCell
        cell.configureCell(resturant: filtereRes[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

