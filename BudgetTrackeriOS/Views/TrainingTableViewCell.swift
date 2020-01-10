//
//  TrainingTableViewCell.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 4/18/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import UIKit

enum Budget {
  case `default`
  case over
  case under
}

class TrainingTableViewCell: UITableViewCell {
  
  @IBOutlet weak var trainingNameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  //  @IBOutlet weak var place holder for button
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  var trainingViewModel: TrainingViewModel? {
    didSet {
      if let trainingViewModel = trainingViewModel {
        trainingNameLabel.text = trainingViewModel.training.name
        priceLabel.text = "$\(trainingViewModel.training.price)"

        if trainingViewModel.isEnrolled {
          accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
          accessoryType = UITableViewCell.AccessoryType.none
        }
      }
    }
  }
  
}
