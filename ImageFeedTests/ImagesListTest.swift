//
//  ImagesListTest.swift
//  ImageFeedTests
//
//  Created by Olga Trofimova on 13.11.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListTest: XCTestCase {
    
    func testImagesListControllerCallViewDidLoad() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssert(presenter.viewDidLoadCalled)
    }
    
    func testPhotosCount() {
        // Given
        let presenter = ImagesListPresenterSpy()
        
        // When
        let photosCount = presenter.photosCount()
        
        // Then
        XCTAssertEqual(photosCount, 10)
    }
    
    func testUpdatedTableViewCall() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        
        // When
        viewController.updateTableViewAnimated(with: 0, newCount: 1)
        
        // Then
        XCTAssert(viewController.updateTableViewAnimatedCalled)
    }
    
    func testGetPhoto() {
        // Given
        let presenter = ImagesListPresenterSpy()
        let testPhoto = Photo(
            id: "123",
            size: CGSize.zero,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "thumbURL",
            largeImageURL: "largeURL",
            isLiked: false
        )
        
        // When
        let presenterPhoto = presenter.getPhoto(for: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertEqual(testPhoto.id, presenterPhoto.id)
        XCTAssertEqual(testPhoto.size, presenterPhoto.size)
        XCTAssertEqual(testPhoto.thumbImageURL, presenterPhoto.thumbImageURL)
        XCTAssertEqual(testPhoto.largeImageURL, presenterPhoto.largeImageURL)
    }
}
