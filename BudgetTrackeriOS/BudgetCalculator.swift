//
//  BudgetCalculator.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 7/12/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import Foundation

struct BudgetCalculator {
  
  func calculateTotal(trainingViewModels: [TrainingViewModel]) -> Int {
    return trainingViewModels.filter { $0.isEnrolled }
      .reduce(0, { $0 + $1.training.price })
  }
}
