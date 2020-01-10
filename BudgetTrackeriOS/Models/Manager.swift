//
//  Manager.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 6/1/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import Foundation

class Manager: Employee {
  let budget: Int
  
  init(firstName: String,
       lastName: String,
       budget: Int) {
    self.budget = budget
    super.init(firstName: firstName,
               lastName: lastName)
  }
  
  init(id: Int,
       firstName: String,
       lastName: String,
       budget: Int) {
    self.budget = budget
    super.init(id: id,
               firstName: firstName,
               lastName: lastName)
  }
  
  private enum CodingKeys: String, CodingKey {
    case budget
    case firstName
    case lastName
    case id
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.budget = try container.decode(Int.self, forKey: .budget)
    let firstName = try container.decode(String.self, forKey: .firstName)
    let lastName = try container.decode(String.self, forKey: .lastName)
    let id = try container.decode(Int.self, forKey: .id)
    super.init(id: id, firstName: firstName, lastName: lastName)
  }
  
  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(firstName, forKey: .firstName)
    try container.encode(lastName, forKey: .lastName)
    try container.encode(budget, forKey: .budget)
    try container.encode(id, forKey: .id)
  }
  
}

