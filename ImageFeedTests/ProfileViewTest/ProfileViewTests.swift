//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Olga Trofimova on 12.11.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testProfileViewControllerCallViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testShowExitAlertCall() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.didTapExitButton()
        
        // Then
        XCTAssertTrue(viewController.showExitAlertCalled)
    }
    
    func testUpdateAvatar() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let url = URL(string: "https://yandex.com/")
        
        // When
        guard let url else {
            XCTFail("avatar url is nil")
            return
        }
        viewController.updateAvatar(wiht: url)
        
        // Then
        XCTAssertTrue(viewController.updateAvararCalled)
    }
    
}
