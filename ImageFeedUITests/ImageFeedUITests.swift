//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Olga Trofimova on 13.11.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
       
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
            
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        // replace with your email
        loginTextField.typeText("<email>")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        // replace with your password
        passwordTextField.typeText("<password>")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["Like button"].tap()
        cellToLike.buttons["Like button"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom In
        image.pinch(withScale: 3, velocity: 1)
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["Back button"]
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
    
        // replace with your name and lastname
        XCTAssertTrue(app.staticTexts["<Name Lastname>"].exists)
        // replace with your @username
        XCTAssertTrue(app.staticTexts["<@username>"].exists)
        
        app.buttons["Logout button"].tap()
        
        app.alerts["Alert"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
