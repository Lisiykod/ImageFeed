//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Olga Trofimova on 13.11.2024.
//

import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        
    }
    
    func fetchNewPhotosPage(for indexPath: IndexPath) {
        
    }
    
    func updateTableView() {
        
    }
    
    func didTapLike(for indexPath: IndexPath, with cell: ImageFeed.ImagesListCell) {
        
    }
    
    func getPhoto(for indexPath: IndexPath) -> Photo {
        return Photo(
            id: "123",
            size: CGSize.zero,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "thumbURL",
            largeImageURL: "largeURL",
            isLiked: false
        )
    }
    
    func photosCount() -> Int {
        return 10
    }
    
    
}
