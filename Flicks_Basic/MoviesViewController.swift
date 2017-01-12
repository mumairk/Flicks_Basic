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


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
  
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  @IBOutlet weak var toggleViewButton: UIButton!
  
  var currentView: UIView!
  var movies: [NSDictionary]?
  var filteredMovies: [NSDictionary]?
  var imageUrl: NSURL!
  var collectionIsFirstView: Bool = true
  
  let apiKey = "08626c78c1c24c6f0e9912f59264d957"
  let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key="
  
  let refreshControl = UIRefreshControl()
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
    filteredMovies = movies
    
    //  toggleViewButton.titleLabel?.text = "Switch"
    
   loadDataFromNetwork()
    
    if collectionIsFirstView {
      loadCollectionView()
    }
    
  }
  
  
  // MARK: - TABLEVIEW
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return filteredMovies?.count ?? 0
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    
    let movie = filteredMovies![indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String
    
    let baseUrl = "http://image.tmdb.org/t/p/w342"
    
    if let posterPath = movie["poster_path"] as? String {
      
      imageUrl = NSURL(string: baseUrl + posterPath)
      fadeInImageRequest(poster: cell.posterView)
      
    }
    
    
    cell.titleLabel.text = title
    cell.overviewLabel.text = overview
    
    return cell
    
    
  }
  
  // MARK: - TOGGLE VIEW
  
  @IBAction func toggleView(_ sender: Any) {
    
    print("Pressed toggle button")
    
    if currentView == self.tableView {
      
      loadCollectionView()
      self.reloadData()
      print("Loading collection view")
    }
      
    else if currentView == self.collectionView {
      
      loadTableView()
      self.reloadData()
      currentView = self.tableView
      
    }
    
  }
  
  func loadCollectionView() {
    
    toggleViewButton.setImage(#imageLiteral(resourceName: "grid48"), for: .normal)
    
    UIView.transition(from: self.tableView, to: self.collectionView, duration: 0, options: .showHideTransitionViews, completion: nil)
    refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
    collectionView.insertSubview(refreshControl, at: 0)
    currentView = self.collectionView
    
  }
  
  func loadTableView() {
    
    toggleViewButton.setImage(#imageLiteral(resourceName: "list48"), for: .normal)

    
    UIView.transition(from: self.collectionView, to: self.tableView, duration: 0, options: .showHideTransitionViews, completion: nil)
    refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    currentView = self.tableView
    
  }
  
  
  // MARK: - COLLECTION VIEW
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return filteredMovies?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
    
    let movie = filteredMovies![indexPath.item]
    
    let title = movie["title"] as! String
    cell.titleLabel.text = title
    
    
    let baseUrl = "http://image.tmdb.org/t/p/w342"
    
    if let posterPath = movie["poster_path"] as? String {
      
      imageUrl = NSURL(string: baseUrl + posterPath)
      fadeInImageRequest(poster: cell.posterImageView)
      
    }
    
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
          self.filteredMovies = self.movies
          self.refreshControl.endRefreshing()
          self.reloadData()
          
        }
      } else {
        self.displayNetworkError()
      }
    }
    task.resume()
  }
  
  func reloadData(){
    
    self.tableView.reloadData()
    self.collectionView.reloadData()
    
  }
  
  func displayNetworkError() {
    
    self.view.viewWithTag(1)?.isHidden = false
    MBProgressHUD.hide(for: self.view, animated: true)
    // add code to hide toggle button
    
  }
  
  func fadeInImageRequest(poster: UIImageView) {
    
    
    let imageRequest = URLRequest(url: imageUrl as URL)
    
    poster.setImageWith(imageRequest as URLRequest, placeholderImage: nil, success: {( imageRequest, imageResponse, image) -> Void in
      
      // image response will be nil if image is cached
      
      if imageResponse != nil {
        print("Image was NOT cached, fade in image")
        poster.alpha = 0.0
        
        
        poster.image = image
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
          poster.alpha = 3.0
        })
      } else {
        print ("Image was cached so just update the image")
        poster.image = image
      }
    },
                        failure: {(imageRequest, imageResponse, error) -> Void in
                          
                          print("Failure to get image")
                          
    })
    
  }
  
  
  // MARK: - REFRESH CONTROL
  
  func refreshControlAction(refreshControl: UIRefreshControl){
    
    loadDataFromNetwork()
    
  }
  
  // MARK: - SEARCH BAR
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filteredMovies = searchText.isEmpty ? movies : movies?.filter({(movie: NSDictionary) -> Bool in
      return (movie["title"] as! String).range(of: searchText, options: .caseInsensitive) != nil
    })
    
    reloadData()
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.searchBar.showsCancelButton = true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.text = ""
    searchBar.resignFirstResponder()
    loadDataFromNetwork()
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

