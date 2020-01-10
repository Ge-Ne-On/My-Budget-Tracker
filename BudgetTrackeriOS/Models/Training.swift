//
//  Training.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 4/16/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import Foundation

final class Training: Codable, CustomStringConvertible {
  
  var id: Int?
  var name: String
  var price: Int
  
  init(name: String,
       price: Int) {
    self.name = name
    self.price = price
  }
  
  var description: String {
    return "\(name) \(price)"
  }
}

extension Array where Element == Training {
  func sum() -> Int {
    return reduce(0) { $0 + $1.price }
  }
}
