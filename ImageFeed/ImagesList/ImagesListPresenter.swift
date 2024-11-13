//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 12.11.2024.
//

import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imageListServie = ImageListService.shared
    private var photos: [Photo] = []
    
    func viewDidLoad() {
        fetchPhotosNextPage()
        updateTableView()
    }
    
    func getPhoto(for indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    func photosCount() -> Int {
        photos.count
    }
    
    func didTapLike(for indexPath: IndexPath, with cell: ImagesListCell) {
        let photo = photos[indexPath.row]
        view?.showProgressHUD()
        imageListServie.changeLike(photoId: photo.id, isLiked: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // синхронизируем фотографии
                self.photos = self.imageListServie.photos
                // изменяем инцикацию лайка картинки
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                view?.hideProgressHUD()
            case .failure(let error):
                view?.hideProgressHUD()
                print("Error in \(#file) \(#function): \(String(describing: error))")
            }
        }
    }
    
    func fetchPhotosNextPage() {
        imageListServie.fetchPhotosNextPage()
    }
    
    func fetchNewPhotosPage(for indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListServie.fetchPhotosNextPage()
        }
    }
    
    func updateTableView() {
        let oldCount = photos.count
        let newCount = imageListServie.photos.count
        photos = imageListServie.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(with: oldCount, newCount: newCount)
        }
    }
}
