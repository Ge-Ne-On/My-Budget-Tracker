//
//  BudgetTrackeriOSUITests.swift
//  BudgetTrackeriOSUITests
//
//  Created by Jonathan Wong on 8/1/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import XCTest

class BudgetTrackeriOSUITests: XCTestCase {

  let application = XCUIApplication()
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    application.launch()

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testManagers() {
    let managersLabel = application.navigationBars["Managers"]
    XCTAssertTrue(managersLabel.exists)
  }

  func testEmployees() {
    let managersLabel = application.navigationBars["Managers"]
    XCTAssertTrue(managersLabel.exists)
    
    application.tables.staticTexts["Jonathan Wong"].tap()
    let employeesLabel = application.navigationBars["Employees"]
    XCTAssertTrue(employeesLabel.exists)
  }
  
  func testTrainings() {
    let managersLabel = application.navigationBars["Managers"]
    XCTAssertTrue(managersLabel.exists)
    
    application.tables.staticTexts["Jonathan Wong"].tap()
    let employeesLabel = application.navigationBars["Employees"]
    XCTAssertTrue(employeesLabel.exists)
    
    application.tables.staticTexts["Ned Martin"].tap()
    let trainingsLabel = application.navigationBars["Trainings"]
    XCTAssertTrue(trainingsLabel.exists)
  }
  
  func testAddAndRemoveTrainings() {
    application.tables.staticTexts["Jonathan Wong"].tap()
    application.tables.staticTexts["Ned Martin"].tap()
    
    let tablesQuery = application.tables
    tablesQuery.cells.containing(.staticText, identifier: "WWDC").element.tap()
    var allCells = application.descendants(matching: .cell)
    var isSelected = allCells.element(boundBy: 0).isSelected
    XCTAssertTrue(isSelected)
    
    tablesQuery.cells.containing(.staticText, identifier: "WWDC").element.tap()
    allCells = application.descendants(matching: .cell)
    isSelected = allCells.element(boundBy: 0).isSelected
    XCTAssertFalse(isSelected)
  }
}
