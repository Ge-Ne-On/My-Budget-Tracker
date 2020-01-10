//
//  Employee.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 4/16/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import Foundation

class Employee: Codable, CustomStringConvertible {
  
  var id: Int?
  var firstName: String
  var lastName: String
  
  init(firstName: String,
       lastName: String) {
    self.firstName = firstName
    self.lastName = lastName
  }
  
  init(id: Int,
       firstName: String,
       lastName: String) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
  }
  
  final class WithTraining: Codable {
    var employee: Employee
    var trainings: [Training]
    
    init(employee: Employee, trainings: [Training]) {
      self.employee = employee
      self.trainings = trainings
    }
  }
  
  var description: String {
    return "\(String(describing: id)) \(firstName) \(lastName)"
  }
}
