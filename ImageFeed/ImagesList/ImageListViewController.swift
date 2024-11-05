//
//  ImageListViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 29.08.2024.
//

import UIKit
import Kingfisher

final class ImageListViewController: UIViewController {
    
    private var photos: [Photo] = []
    private let imageListServie = ImageListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    let placeholder: UIImage? = UIImage(named: "placeholder")
    private var imageState: ImageCellState = .loading
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBlack
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "RU_ru")
        return formatter
    }()
    
    private enum ImageCellState {
        case loading
        case error
        case loaded(UIImage)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .ypBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        setConstraints()
        imageListServie.fetchPhotosNextPage()
        updateTableViewAnimated()
        imageListServiceObserver = NotificationCenter.default.addObserver(
                    forName: ImageListService.didChangeNotification,
                    object: nil,
                    queue: .main) { [weak self] _ in
            guard let self else { return }
            self.updateTableViewAnimated()
        }
//        if #available(iOS 15.0, *) {
//            UITableView.appearance().isPrefetchingEnabled = false
//        }
    }
    
    // MARK: - Private Methods
    private func showSingleImage(with indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        guard let imageURL = URL(string: photos[indexPath.row].largeImageURL) else { return }
        singleImageViewController.imageURL = imageURL
        singleImageViewController.image = placeholder
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    private func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // устанавливаем делегата
        cell.delegate = self
        // настраиваем картинку
        guard let imageURL = URL(string: photos[indexPath.row].thumbImageURL) else {
            return
        }
        
        cell.mainImage.kf.indicatorType = .activity
        cell.mainImage.kf.setImage(with: imageURL, placeholder: placeholder) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                imageState = .loaded(image.image)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                imageState = .error
//                cell.mainImage.image = placeholder
                print("Set image error: \(error.localizedDescription)")
            }
        }
        
        // настраиваем дату
        if let date = photos[indexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        // настраиваем лайк
        let isFavorite = photos[indexPath.row].isLiked
        cell.setIsLiked(isFavorite)
        
////        cell.removeAnimation()
//        switch imageState {
//        case .loading:
//            cell.animationGradient()
//        case .error:
//            cell.mainImage.image = placeholder
//            cell.removeAnimation()
//        case .loaded(_):
////            cell.mainImage.image = image
//            cell.removeAnimation()
//        }
    }
    
    // метод для добавления новых фотографий
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListServie.photos.count
        photos = imageListServie.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    private func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

extension ImageListViewController: UITableViewDataSource {
    // реализуем требуемые методы протокола
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // говорим какую ячейку будем переиспользовать
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        // приводим ячейку к нужному нам типу или возвращаем дефолтную
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        // конфигурирем ячейку
        configureCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
}

extension ImageListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImage(with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

       let image = photos[indexPath.row]
//        // высчитываем высоту ячейки
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        guard image.size.width != 0 else { return 0 }
        let imageWidth = image.size.width
        let scale = imageViewWidth/imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom

        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListServie.fetchPhotosNextPage()
        }
    }
}

extension ImageListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListServie.changeLike(photoId: photo.id, isLiked: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // синхронизируем фотографии
                self.photos = self.imageListServie.photos
                // изменяем инцикацию лайка картинки
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                //TODO: - показать алерт с ошибкой
            }
        }
    }
}
