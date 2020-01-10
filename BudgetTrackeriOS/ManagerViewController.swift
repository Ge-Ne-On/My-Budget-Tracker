//
//  ManagerViewController.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 5/18/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import UIKit

class ManagerViewController: UIViewController {

  @IBOutlet weak var managerTableView: UITableView!

  let apiClient = ApiClient(session: URLSession.shared, resourcePath: "managers")
  
  var managers: [Manager] = []
  var manager: Manager?
  var managerColor: UIColor?
  
  override func viewDidLoad() {
    let nib = UINib(nibName: "BudgetTableViewCell", bundle: nil)
    managerTableView.register(nib, forCellReuseIdentifier: "BudgetTableViewCell")
    
    managerTableView.estimatedRowHeight = 60.0
    managerTableView.rowHeight = UITableView.automaticDimension
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadManagers()
  }
  
  func loadManagers() {
    apiClient.fetchResources { (result: Result<[Manager], ApiError>) in
      switch result {
      case .success(let managers):
        print("managers: \(managers)")
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.managers = managers
          self.managerTableView.reloadData()
        }
      case .failure(let error):
        print("error \(error)")
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showEmployeeViewController" {
      let vc = segue.destination as! EmployeeViewController
      vc.manager = manager
      vc.managerColor = managerColor
    }
  }
}

extension ManagerViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return managers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "BudgetTableViewCell",
      for: indexPath) as! BudgetTableViewCell
    cell.employee = managers[indexPath.row]
    cell.color = AppColors.shared.managerColors[indexPath.row]
    
    return cell
  }
  
}

extension ManagerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    manager = managers[indexPath.row]
    managerColor = AppColors.shared.managerColors[indexPath.row]
    performSegue(withIdentifier: "showEmployeeViewController", sender: self)
  }
}
