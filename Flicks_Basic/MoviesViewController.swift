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
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var toggleButton: UIBarButtonItem!
  
  var searchBar: UISearchBar = UISearchBar()
  
  var currentView: UIView!
  var movies: [NSDictionary]?
  var movie: NSDictionary!
  var name: String?
  var overview: String?
  var filteredMovies: [NSDictionary]?
  var imageUrl: NSURL!
  var collectionIsFirstView: Bool = true
  
  var endpoint: String!
  
  let refreshControl = UIRefreshControl()
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
    filteredMovies = movies
    
    self.navigationItem.titleView = searchBar
    self.searchBar.barStyle = .black
    self.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
    
    self.navigationController?.navigationBar.barStyle = .black
    self.tabBarController?.tabBar.barStyle = .black
    self.tabBarController?.tabBar.tintColor = UIColor.white
    
    loadDataFromNetwork()
    
    if collectionIsFirstView {
      loadCollectionView()
    } else {
      loadTableView()
    }
    
  }
  
  
  // MARK: - TABLEVIEW
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    var count: Int
    
    if endpoint == "myFavorites"{
    
      let delegate = UIApplication.shared.delegate as! AppDelegate
      let myFavMovies = delegate.myFavorites as [NSDictionary]
      count = myFavMovies.count
    } else {
      count = filteredMovies?.count ?? 0
    }
    
    print("Count: \(count)")
    return count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    
    if endpoint == "myFavorites"{
      
      let delegate = UIApplication.shared.delegate as! AppDelegate
      let myFavMovies = delegate.myFavorites as [NSDictionary]
      let movie = myFavMovies[indexPath.row]
      name = movie["title"] as? String
      overview = movie["overview"] as? String
      
      let baseUrl = "http://image.tmdb.org/t/p/w342"
      
      if let posterPath = movie["poster_path"] as? String {
        
        imageUrl = NSURL(string: baseUrl + posterPath)
        fadeInImageRequest(poster: cell.posterView)
      }
    } else {
      
      let movie = filteredMovies![indexPath.row]
      name = movie["title"] as? String
      overview = movie["overview"] as? String
      
      let baseUrl = "http://image.tmdb.org/t/p/w342"
      
      if let posterPath = movie["poster_path"] as? String {
        
        imageUrl = NSURL(string: baseUrl + posterPath)
        fadeInImageRequest(poster: cell.posterView)
      }
    }

    
    cell.titleLabel.text = name
    cell.overviewLabel.text = overview
    
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor(red: 0.4078, green: 0.3882, blue: 0.498, alpha: 0.4) /* #68637f */
    
    cell.selectedBackgroundView = backgroundView
    
    return cell
    
  }
  
  
  
  // MARK: - TOGGLE VIEW
  
  
  @IBAction func toggleViewType(_ sender: UIBarButtonItem) {
    
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
  
  func hideToggleButton() {
    self.navigationItem.rightBarButtonItem = nil
  }
  
  
  func loadCollectionView() {
    
    navigationItem.rightBarButtonItem?.image = UIImage(named: "grid_medgrey24")
    
    UIView.transition(from: self.tableView, to: self.collectionView, duration: 0, options: .showHideTransitionViews, completion: nil)
    refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
    collectionView.insertSubview(refreshControl, at: 0)
    currentView = self.collectionView
    
    
  }
  
  func loadTableView() {
    
    navigationItem.rightBarButtonItem?.image = UIImage(named: "listgrid_medgrey24")
    UIView.transition(from: self.collectionView, to: self.tableView, duration: 0, options: .showHideTransitionViews, completion: nil)
    self.tableView.backgroundColor = UIColor.black
    
    
    
    
    refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    currentView = self.tableView
    
    
  }
  
  
  // MARK: - COLLECTION VIEW
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   
    var count: Int
    
    if endpoint == "myFavorites"{
      
      let delegate = UIApplication.shared.delegate as! AppDelegate
      let myFavMovies = delegate.myFavorites as [NSDictionary]
      count = myFavMovies.count
    } else {
      count = filteredMovies?.count ?? 0
    }
    
    print("Count: \(count)")
    return count

  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
    
    if endpoint == "myFavorites"{
      
      let delegate = UIApplication.shared.delegate as! AppDelegate
      let myFavMovies = delegate.myFavorites as [NSDictionary]
      let movie = myFavMovies[indexPath.item]
      name = movie["title"] as? String
      overview = movie["overview"] as? String
      
      let baseUrl = "http://image.tmdb.org/t/p/w342"
      
      if let posterPath = movie["poster_path"] as? String {
        
        imageUrl = NSURL(string: baseUrl + posterPath)
        fadeInImageRequest(poster: cell.posterImageView)
      }
    } else {
      
      let movie = filteredMovies![indexPath.item]
      name = movie["title"] as? String
      overview = movie["overview"] as? String
      
      let baseUrl = "http://image.tmdb.org/t/p/w342"
      
      if let posterPath = movie["poster_path"] as? String {
        
        imageUrl = NSURL(string: baseUrl + posterPath)
        fadeInImageRequest(poster: cell.posterImageView)

      }
    }

    
    
    cell.titleLabel.text = title
    
    return cell
    
  }
  
  
  // MARK: - NETWORK REQUEST
  
  func loadDataFromNetwork(){
    
    if endpoint == "myFavorites"{
      let delegate = UIApplication.shared.delegate as! AppDelegate
      let myFavMovies = delegate.myFavorites as [NSDictionary]
      self.movies = myFavMovies
      print("SAVED MOVIES ARE: \(self.movies!)")
      self.tableView.reloadData()
    }
    else {
    
    let apiKey = "08626c78c1c24c6f0e9912f59264d957"
    let urlString = "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key="
    
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
          
          //    self.searchBar.isHidden = false
          
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
  }
  
  func reloadData(){
    
    self.tableView.reloadData()
    self.collectionView.reloadData()
    
  }
  
  func displayNetworkError() {
    
    self.view.viewWithTag(1)?.isHidden = false
    hideToggleButton()
    self.searchBar.isHidden = true
    MBProgressHUD.hide(for: self.view, animated: true)
    
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
  
  
  
  
  
  
  
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    print("prepare for segue called")
    
    if segue.identifier == "CollectionView" {
      
      let cell = sender as! UICollectionViewCell
      let indexPath = collectionView.indexPath(for: cell)
      movie = movies![indexPath!.item]
      
    } else if segue.identifier == "TableView" {
      
      let cell = sender as! UITableViewCell
      let indexPath = tableView.indexPath(for: cell)
      movie = movies![(indexPath?.row)!]
      
    }
    
    let detailViewController = segue.destination as! DetailViewController
    detailViewController.movie = movie
    
    print("Movie: \(movie!)")
    
  }
  
  
}

