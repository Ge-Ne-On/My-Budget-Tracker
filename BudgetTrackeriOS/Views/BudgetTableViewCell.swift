//
//  EmployeeTableViewCell.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 4/16/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var budgetLabel: UILabel!
  @IBOutlet weak var budgetView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    budgetLabel.text = ""
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    if selected {
      budgetView.backgroundColor = color
    }
  }
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    
    if highlighted {
      budgetView.backgroundColor = color
    }
  }
  
  var color: UIColor? {
    didSet {
      budgetView.backgroundColor = color
    }
  }
  
  var budget: Int = 0 {
    didSet {
      budgetLabel.text = "\(budget)"
    }
  }
  
  var employee: Employee? {
    didSet {
      
      if let employee = employee {
        nameLabel.text = "\(employee.firstName) \(employee.lastName)"
      }
    }
  }
  
}
