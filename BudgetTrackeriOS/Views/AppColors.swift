//
//  AppColors.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 6/2/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import UIKit

class AppColors {
  
  static let shared = AppColors()
  
  let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
  let green = UIColor(red: 155/255.0, green: 200/255.0, blue: 80/255.0, alpha: 1.0)
  let red = UIColor(red: 171/255.0, green: 67/255.0, blue: 53/255.0, alpha: 1.0)
  let blue = UIColor(red: 42/255.0, green: 159/255.0, blue: 188/255.0, alpha: 1.0)
  
  let orange = UIColor(red: 240/255.0, green: 90/255.0, blue: 40/255.0, alpha: 1.0)
  let plum = UIColor(red: 166/255.0, green: 46/255.0, blue: 92/255.0, alpha: 1.0)
  let lightPlum = UIColor(red: 166/255.0, green: 46/255.0, blue: 92/255.0, alpha: 0.6)
  let lightGreen = UIColor(red: 155/255.0, green: 200/255.0, blue: 80/255.0, alpha: 0.6)
  let purple = UIColor(red: 103/255.0, green: 91/255.0, blue: 167/255.0, alpha: 1.0)
  let lightPurple = UIColor(red: 103/255.0, green: 91/255.0, blue: 167/255.0, alpha: 0.6)
    let lightOrange = UIColor(red: 240/255.0, green: 90/255.0, blue: 40/255.0, alpha: 0.6)
    let lightBlue = UIColor(red: 42/255.0, green: 159/255.0, blue: 188/255.0, alpha: 0.6)
  
  let managerColors: [UIColor]
  
  private init() {
    managerColors = [orange,
                     plum,
                     purple,
                     lightGreen,
                     lightOrange,
                     lightPlum,
                     lightPurple,
                     lightBlue
                     ]
  }
  
  class func random() -> UIColor {
    let randomInt = Int.random(in: 0..<AppColors.shared.managerColors.count)
    return AppColors.shared.managerColors[randomInt]
  }
  
  
}
