//
//  EmployeeViewController.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 4/16/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import UIKit

class EmployeeViewController: UIViewController {
  
  @IBOutlet weak var employeeTableView: UITableView!
  
  var managerColor: UIColor?
  
  let apiClient = ApiClient(session: URLSession.shared, resourcePath: "managers")
  
  var manager: Manager?
  var employee: Employee?
  var employees: [Employee] = []
  var trainingDownloads: [TrainingDownload] = []
  let pendingOperations = PendingOperations()
  var selectedIndexPath: IndexPath?
  var employeeTrainingsTotal = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let managerId = manager?.id else {
      return
    }
    apiClient.resourceURL.appendPathComponent("\(managerId)/employees")
    
    let nib = UINib(nibName: "BudgetTableViewCell", bundle: nil)
    employeeTableView.register(nib, forCellReuseIdentifier: "BudgetTableViewCell")
    
    employeeTableView.estimatedRowHeight = 60.0
    employeeTableView.rowHeight = UITableView.automaticDimension
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadEmployees()
  }
  
  func loadEmployees() {
    apiClient.fetchResources { [weak self] (result: Result<[Employee], ApiError>) in
      switch result {
      case .success(let employees):
        guard let self = self else { return }
        self.employees = employees
        
        employees.forEach { employee in
          if let employeeId = employee.id {
            self.trainingDownloads.append(TrainingDownload(employeeId: employeeId))
          }
        }
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.employeeTableView.reloadData()
        }
      case .failure(let error):
        print("error \(error)")
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showTrainingViewController" {
      let vc = segue.destination as! TrainingViewController
      vc.employee = employee
      vc.delegate = self
    }
  }
  
}

extension EmployeeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return employees.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "BudgetTableViewCell",
      for: indexPath) as! BudgetTableViewCell
    
    cell.employee = employees[indexPath.row]
    
    let trainingDetails = trainingDownloads[indexPath.row]
    var total = 0
    trainingDetails.trainings?.forEach { training in
      total += training.price
    }
    cell.budget = total
    
    switch trainingDetails.state {
    case .new:
      startOperations(for: trainingDetails, at: indexPath)
    case .downloaded:
      print("downloaded")
    case .failed:
      print("failed")
    }
    
    if let managerColor = managerColor {
      cell.color = managerColor
    }
    
    return cell
  }
  
  func startOperations(for trainingDownload: TrainingDownload, at indexPath: IndexPath) {
    switch (trainingDownload.state) {
    case .new:
      startDownload(for: trainingDownload, at: indexPath)
    default:
      print("do nothing")
    }
  }
  
  func startDownload(for trainingDownload: TrainingDownload, at indexPath: IndexPath) {
    guard pendingOperations.downloadsInProgress[indexPath] == nil else {
      return
    }
    
    let downloader = TrainingDownloader(trainingDownload: trainingDownload)
    downloader.completionBlock = {
      if downloader.isCancelled {
        return
      }
      DispatchQueue.main.async {
        if downloader.trainingDownload.state == .downloaded {
          downloader.trainingDownload.trainings?.forEach { training in
            self.employeeTrainingsTotal += training.price
          }
        }
        if self.employeeTrainingsTotal > (self.manager?.budget)! {
          print("over budget")
        }
        
        self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
        self.employeeTableView.reloadRows(at: [indexPath], with: .fade)
        self.employeeTableView.reloadSections(IndexSet(0..<1), with: .automatic)
      }
    }
    pendingOperations.downloadsInProgress[indexPath] = downloader
    pendingOperations.downloadQueue.addOperation(downloader)
  }
}

extension EmployeeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    employee = employees[indexPath.row]
    performSegue(withIdentifier: "showTrainingViewController", sender: self)
  }
}

extension EmployeeViewController: TrainingViewControllerDelegate {
  func didUpdateTrainings(_ trainings: [Training]) {
    guard let indexPath = selectedIndexPath else {
      return
    }
    
    trainingDownloads[indexPath.row].trainings = trainings
    
    self.employeeTrainingsTotal = trainingDownloads.sum()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: employeeTableView.frame.size.width, height: 50))
    
    let totalLabel = UILabel()
    totalLabel.textColor = AppColors.shared.white
    totalLabel.translatesAutoresizingMaskIntoConstraints = false
    headerView.addSubview(totalLabel)
    totalLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
    totalLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
    
    totalLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.thin)
    
    // budget calculation
    guard let manager = manager else { return headerView }
    totalLabel.text = "$\(manager.budget)"
    
    if employeeTrainingsTotal < (self.manager?.budget)! {
      headerView.backgroundColor = AppColors.shared.green
    } else {
      headerView.backgroundColor = AppColors.shared.red
    }
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 100
  }
  
}
