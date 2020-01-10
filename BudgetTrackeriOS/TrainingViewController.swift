//
//  TrainingViewController.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 4/17/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import UIKit

protocol TrainingViewControllerDelegate: class {
  func didUpdateTrainings(_ trainings: [Training])
}

class TrainingViewController: UIViewController {

  @IBOutlet weak var trainingTableView: UITableView!

  var trainings: [Training] = []
  var trainingViewModels: [TrainingViewModel] = []
  var employee: Employee?
  var trainingTotal = 0
  var budget = 3000
  var budgetCalculator = BudgetCalculator()
  var didChangeTrainings = false
  weak var delegate: TrainingViewControllerDelegate?

  var apiClient = ApiClient(session: URLSession.shared)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Trainings"
    view.tintColor = AppColors.shared.lightBlue
    loadTrainings { [weak self] in
      self?.trainingsForEmployee()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if didChangeTrainings {
      let trainings = trainingViewModels.filter {
        $0.isEnrolled
        }.map {
          $0.training
      }
      delegate?.didUpdateTrainings(trainings)
    }
  }

  func calculateBudget() {
    self.trainingTotal = budgetCalculator.calculateTotal(trainingViewModels: trainingViewModels)
  }

  func loadTrainings(completion: @escaping () -> ()) {
    apiClient.path = "trainings"
    apiClient.fetchResources { (result: Result<[Training], ApiError>) in
      switch result {
      case .success(let trainings):
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.trainings = trainings
          completion()
        }
      case .failure(let error):
        print("error \(error)")
      }
    }
  }
  
  func trainingsForEmployee() {
    guard let employeeId = employee?.id else { return }
    apiClient.path = "employees/\(employeeId)/trainings"
    apiClient.fetchResource { [weak self] (result: Result<Employee.WithTraining, ApiError>) in
      switch result {
      case .success(let employeeTrainings):
        guard let self = self else { return }
        self.trainings.forEach { training in
          let exists = employeeTrainings.trainings.first(where: {$0.id == training.id})
          var enrolled = false
          if exists != nil {
            enrolled = true
          }
          self.trainingViewModels.append(TrainingViewModel(training: training, isEnrolled: enrolled))
        }
        self.calculateBudget()
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.trainingTableView.reloadData()
        }
      case .failure(let error):
        print("error getting trainings \(error)")
      }
    }
  }
}

extension TrainingViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return trainingViewModels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TrainingTableViewCell", for: indexPath) as! TrainingTableViewCell

    let trainingViewModel = trainingViewModels[indexPath.row]
    cell.trainingViewModel = trainingViewModel

    return cell
  }
}

extension TrainingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: trainingTableView.frame.size.width, height: 100))
    
    let totalLabel = UILabel()
    totalLabel.textColor = AppColors.shared.white
    totalLabel.translatesAutoresizingMaskIntoConstraints = false
    headerView.addSubview(totalLabel)
    totalLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
    totalLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
    
    totalLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.thin)
    
    // budget calculation
    totalLabel.text = "$\(trainingTotal)"
    
    if trainingTotal < budget {
      headerView.backgroundColor = AppColors.shared.green
    } else {
      headerView.backgroundColor = AppColors.shared.red
    }
    
    return headerView
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 100
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    didChangeTrainings = true
    tableView.deselectRow(at: indexPath, animated: true)
    
    let trainingViewModel = trainingViewModels[indexPath.row]

    guard let trainingId = trainingViewModel.training.id, let employeeId = employee?.id else {
      return
    }
    
    if trainingViewModel.isEnrolled {
      apiClient.delete(fromPath: "trainings",
                       fromResourceId: trainingId,
                       toPath: "employees",
                       toResourceId: employeeId) { [weak self] statusCode in
                        print("statusCode: \(statusCode)")
                        
                        self?.trainingViewModels[indexPath.row].isEnrolled = false
                        DispatchQueue.main.async { [weak self] in
                          guard let self = self else { return }
                          self.calculateBudget()
                          self.trainingTableView.reloadSections(IndexSet(0..<1), with: .automatic)
                        }
      }
    } else {
      apiClient.save(fromPath: "trainings",
                     fromResourceId: trainingId,
                     toPath: "employees",
                     toResourceId: employeeId) { [weak self] statusCode in
                      print("statusCode: \(statusCode)")
                      
                      self?.trainingViewModels[indexPath.row].isEnrolled = true
                      DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.calculateBudget()
                        self.trainingTableView.reloadSections(IndexSet(0..<1), with: .automatic)
                      }
      }
    }

    
  }
}
