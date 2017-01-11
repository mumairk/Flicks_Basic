//
//  MoviesViewController.swift
//  Flicks_Basic
//
//  Created by Barbara Ristau on 1/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!

  var movies: [NSDictionary]?
  
  let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
  let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key="

  
    override func viewDidLoad() {
        super.viewDidLoad()
      
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
      
        // add refresh control to tableview
       tableView.insertSubview(refreshControl, at: 0)
      
        tableView.dataSource = self
        tableView.delegate = self
      
        loadDataFromNetwork()
      
  }

  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    if let movies = movies {
      return movies.count
    } else {
      return 0
    }
    
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    
    let movie = movies![indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String
    
    let baseUrl = "http://image.tmdb.org/t/p/w342"
    let posterPath = movie["poster_path"] as! String
    
    let imageUrl = NSURL(string: baseUrl + posterPath)
    cell.posterView.setImageWith(imageUrl as! URL)

    
    cell.titleLabel.text = title
    cell.overviewLabel.text = overview
  
    //cell.textLabel?.text = "row \(indexPath.row)"
    //print("row\(indexPath.row)")
    
    return cell
    
    
  }
  
  
// MARK: - NETWORK REQUEST
      
      func loadDataFromNetwork(){

        let url = URL(string: urlString + apiKey)!

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
     
        // show Progress HUD
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
          
          if let data = data {
            if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
              print(dataDictionary)
              
              // Hide Progress HUD 
              MBProgressHUD.hide(for: self.view, animated: true)
              
              self.movies = dataDictionary["results"] as? [NSDictionary]
              self.tableView.reloadData()
            }
          } else {
                  self.view.viewWithTag(1)?.isHidden = false
                  MBProgressHUD.hide(for: self.view, animated: true)
          }
        }
        task.resume()
        
      }

  
  // makes a network request to get updated data 
  // updates the tableview with the new data
  // hides the refresh control
 
  
  func refreshControlAction(refreshControl: UIRefreshControl){
    
    let url = URL(string: urlString + apiKey)!
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    
    let session = URLSession(configuration: URLSessionConfiguration.default,
                               delegate: nil, delegateQueue: OperationQueue.main
    )
    
   let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in

      // use new data to update the data source
    
      if let data = data {
        if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
        
        self.movies = dataDictionary["results"] as? [NSDictionary]

      // reload the table view now that there is new data
      self.tableView.reloadData()
    
      // tell refresh control to stop spinning
      refreshControl.endRefreshing()
          
        }
      }
      
    });
    task.resume()
    
  }
  
  func showNetworkError() {
    

  }
  
  
  
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
