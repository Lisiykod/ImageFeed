//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Olga Trofimova on 13.11.2024.
//

import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
   
    var presenter: ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled: Bool = false
    
    func updateTableViewAnimated(with oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func showDidTapLikeError() { }
    
    func showProgressHUD() { }
    
    func hideProgressHUD() { }
    
    
}
