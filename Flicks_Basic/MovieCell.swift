//
//  MovieCell.swift
//  Flicks_Basic
//
//  Created by Barbara Ristau on 1/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
  
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var overviewLabel: UILabel!

  @IBOutlet weak var posterView: UIImageView!
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
