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
  let lowResBaseUrl: String = "https://image.tmdb.org/t/p/w45"
  let highResBaseUrl: String = "https://image.tmdb.org/t/p/original"
  
  let baseUrl: String = "http://image.tmdb.org/t/p/w342"
  
  override func viewDidLoad() {
        super.viewDidLoad()
    
    let title = movie["title"] as? String
    titleLabel.text = title!
    self.navigationItem.title = title!
    

    let overview = movie["overview"] as? String
    overviewLabel.text = overview!
    
    overviewLabel.sizeToFit()
    
   loadImage()
  
    let navigationBar = navigationController?.navigationBar
    
    let shadow = NSShadow()
    shadow.shadowColor = UIColor.gray.withAlphaComponent(0.5)
    shadow.shadowOffset = .init(width: 1, height: 1)
    shadow.shadowBlurRadius = 2;
    navigationBar?.titleTextAttributes = [
      NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22),
      NSForegroundColorAttributeName : UIColor(red: 0.9176, green: 0.9255, blue: 0.9765, alpha: 1.0) /* #eaecf9 */,
        NSShadowAttributeName : shadow
    ]
        
    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
    
    print(movie) 
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  func loadImage() {
    
    if let posterPath = movie["poster_path"] as? String {

      let lowResPath: String = lowResBaseUrl + posterPath
      let highResPath: String = highResBaseUrl + posterPath
      
      let lowResImageRequest = URLRequest(url: NSURL(string: lowResPath) as! URL)
      let highResImageRequest = URLRequest(url: NSURL(string: highResPath) as! URL)
      
      self.posterImageView.setImageWith(lowResImageRequest, placeholderImage: nil, success: {(lowResImageRequest, lowResImageResponse, lowResImage) -> Void in
        
        self.posterImageView.alpha = 0.0
        self.posterImageView.image = lowResImage
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
          
          self.posterImageView.alpha = 1.0
          
        }, completion: { (success) -> Void in
          
          self.posterImageView.setImageWith(highResImageRequest, placeholderImage: lowResImage, success: { (highResImageRequest, highResImageResponse, highResImage) -> Void in
            
              self.posterImageView.image = highResImage
            
          },
                                            failure: { (request, response, error) -> Void in
                       // Do something 
                                              
          })
        })
        
      },
                                        failure: { (request, response, error) -> Void in
                                          
                                        // do something
                                          
      })
      
      
      //let imageUrl = NSURL(string: baseUrl + posterPath)
      //posterImageView.setImageWith(imageUrl as! URL)
  
    
  }
  
  
  }
  

    // MARK: - Navigation

   // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
    
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
  //  }


}
