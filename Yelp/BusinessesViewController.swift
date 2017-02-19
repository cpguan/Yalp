//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    
//    var searchSettings = YelpSearchSetting()
    
    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var SearchSetting = YelpSearchSetting()
    var searchTerm: String = "Restaurants"
    var isMoreDataLoading = false
    var theoffset = 0
    var filteredCategories:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        self.searchBar.placeholder = "Restaurants"
        self.searchBar.tintColor = UIColor.white
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.74, green: 0.15, blue: 0.15, alpha: 0.9)

        doSearch()
        tableView.reloadData()
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
      
    }
        func doSearch(){

            Business.searchWithTerm(term: "\(searchTerm)", offset: theoffset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
                self.businesses = businesses
                self.tableView.reloadData()
            
                if let businesses = businesses {
                    for business in businesses {
                        print(business.name!)
                        print(business.address!)
                    }
                }
                self.tableView.reloadData()
            })
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        doSearch()
        refreshControl.endRefreshing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                    isMoreDataLoading = true
                    loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
    
        Business.searchWithTerm(term: searchTerm, offset: theoffset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.isMoreDataLoading = false
            self.theoffset += 20
            self.businesses.append(contentsOf: businesses!)
            self.tableView.reloadData()
        })
    }
}


    
extension BusinessesViewController: UISearchBarDelegate {
        
        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }
        
        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(false, animated: true)
            return true
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            SearchSetting.searchString = searchBar.text
            searchBar.resignFirstResponder()
            searchTerm = SearchSetting.searchString!
            doSearch()
        }
}

    /*
     // MARK:- Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    

