//
//  MoviesViewController.swift
//  Flicks_Basic
//
//  Created by Barbara Ristau on 1/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!

  var movies: [NSDictionary]?
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
      
      // MARK: - NETWORK REQUEST
      let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
      let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
      let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
      let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
      let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        if let data = data {
          if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
            print(dataDictionary)
            
            self.movies = dataDictionary["results"] as? [NSDictionary]
            self.tableView.reloadData()
          }
        }
      }
      task.resume()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    cell.titleLabel.text = title
    cell.overviewLabel.text = overview
    
    
    //cell.textLabel?.text = "row \(indexPath.row)"
    //print("row\(indexPath.row)")
    
    return cell
    
    
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
