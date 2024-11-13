//
//  ImageListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 13.11.2024.
//

import Foundation

protocol ImageListPresenterProtocol: AnyObject {
   var view: ImageListViewControllerProtocol? { get set }
   func viewDidLoad()
   func fetchPhotosNextPage()
   func fetchNewPhotosPage(for indexPath: IndexPath)
   func updateTableView()
   func didTapLike(for indexPath: IndexPath, with cell: ImagesListCell)
   func getPhoto(for indexPath: IndexPath) -> Photo
   func photosCount() -> Int
}
