//
//  DetailViewController.swift
//  Flicks_Basic
//
//  Created by Barbara Ristau on 1/14/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController {

  
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  
  
  @IBOutlet weak var infoView: UIView!
  
  
  var movie: NSDictionary!
  
  override func viewDidLoad() {
        super.viewDidLoad()
    
    let title = movie["title"] as? String
    titleLabel.text = title!
    
    let overview = movie["overview"] as? String
    overviewLabel.text = overview!
    
    overviewLabel.sizeToFit()
    
    let baseUrl = "http://image.tmdb.org/t/p/w342"
    
    if let posterPath = movie["poster_path"] as? String {
      
      let imageUrl = NSURL(string: baseUrl + posterPath)
      posterImageView.setImageWith(imageUrl as! URL)
      
    }
    
    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
    
    print(movie) 
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

   // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
    
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
  //  }


}
