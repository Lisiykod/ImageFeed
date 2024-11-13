//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 29.08.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol?
    private var imageListServiceObserver: NSObjectProtocol?
    private let placeholder: UIImage? = UIImage(named: "placeholder")
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBlack
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "RU_ru")
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .ypBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        setConstraints()
        presenter?.viewDidLoad()
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.presenter?.updateTableView()
            }
    }
    
    // MARK: - Public Methods
    // метод для добавления новых фотографий
    func updateTableViewAnimated(with oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func showProgressHUD() {
        UIBlockingProgressHUD.show()
    }
    
    func hideProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }
    
    // MARK: - Private Methods
    private func showSingleImage(with indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        guard let photo = presenter?.getPhoto(for: indexPath) else { return }
        guard let imageURL = URL(string: photo.largeImageURL) else { return }
        singleImageViewController.imageURL = imageURL
        singleImageViewController.image = placeholder
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    private func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // устанавливаем делегата
        cell.delegate = self
        
        // получаем фотографию
        guard let photo = presenter?.getPhoto(for: indexPath) else {
            return
        }
        
        // настраиваем картинку
        guard let imageURL = URL(string: photo.thumbImageURL) else {
            return
        }
        
        cell.mainImage.kf.indicatorType = .activity
        cell.mainImage.kf.setImage(with: imageURL, placeholder: placeholder) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                print("Image loaded: \(image.image)")
            case .failure(let error):
                cell.mainImage.image = placeholder
                print("Set image error: \(error.localizedDescription)")
            }
        }
        
        // настраиваем дату
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        // настраиваем лайк
        let isFavorite = photo.isLiked
        cell.setIsLiked(isFavorite)
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

extension ImagesListViewController: UITableViewDataSource {
    // реализуем требуемые методы протокола
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photosCount() ?? 0
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

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImage(with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let image = presenter?.getPhoto(for: indexPath) else {
            return 200
        }
        // высчитываем высоту ячейки
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        guard image.size.width != 0 else { return 0 }
        let imageWidth = image.size.width
        let scale = imageViewWidth/imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.fetchNewPhotosPage(for: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        presenter?.didTapLike(for: indexPath, with: cell)
    }
}
