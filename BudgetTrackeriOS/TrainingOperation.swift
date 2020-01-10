//
//  TrainingOperation.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 6/28/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import Foundation

enum DownloadState {
  case new
  case downloaded
  case failed
}

class TrainingDownload: CustomStringConvertible {
  let employeeId: Int
  var state = DownloadState.new
  var trainings: [Training]?
  
  init(employeeId: Int) {
    self.employeeId = employeeId
  }
  
  var description: String {
    return """
    EmployeeId: \(employeeId)
    State: \(state)
    Trainings: \(String(describing: trainings ?? nil))
"""
  }
}

extension Array where Element == TrainingDownload {
  func sum() -> Int {
    return reduce(0) { $0 + ($1.trainings?.sum() ?? 0) }
  }
}

class TrainingDownloader: Operation {
  let trainingDownload: TrainingDownload
  let apiClient = ApiClient(session: URLSession.shared, resourcePath: "employees")
  
  init(trainingDownload: TrainingDownload) {
    self.trainingDownload  = trainingDownload
    self.apiClient.path = "employees/\(trainingDownload.employeeId)/trainings"
  }
  
  override func main() {
    if isCancelled {
      return
    }
    
    apiClient.fetchResource { (result: Result<Employee.WithTraining, ApiError>) in
      if self.isCancelled {
        return
      }
      switch result {
      case .success(let employeeAndTrainings):
        print(" trainings: \(employeeAndTrainings)")
        self.trainingDownload.state = .downloaded
        self.trainingDownload.trainings = employeeAndTrainings.trainings
      case .failure(let error):
        print(" can't get trainings \(error)")
        self.trainingDownload.state = .failed
      }
    }
  }
  
  override var description: String {
    return "\(trainingDownload)"
  }
}

class PendingOperations {
  lazy var downloadsInProgress: [IndexPath: Operation] = [:]
  lazy var downloadQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "Download queue"
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
}
