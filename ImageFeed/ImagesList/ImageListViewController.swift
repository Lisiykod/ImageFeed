//
//  ImageListViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 29.08.2024.
//

import UIKit

final class ImageListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
//    private let showSingleImageSegueIdentifier: String = "ShowSingleImage"
    private let currentDate: Date = Date()
    
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
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Public Methods
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showSingleImageSegueIdentifier {
//            guard
//                let viewController = segue.destination as? SingleImageViewController,
//                let indexPath = sender as? IndexPath
//            else {
//                assertionFailure("Invalid segue destination")
//                return
//            }
//            
//            let image = UIImage(named: photosName[indexPath.row])
//            viewController.image = image
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    
    func showSingleImage(with indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        let image = UIImage(named: photosName[indexPath.row])
        singleImageViewController.image = image
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    // MARK: - Private Methods
    private func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        // настраиваем картинку
        cell.mainImage.image = image
        
        // настраиваем дату
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        // настраиваем лайк
        let isFavorite = indexPath.row % 2 == 0
        let imageName = isFavorite ? UIImage(named: "favorite") : UIImage(named: "not_favorite")
        cell.favoriteImageButton.setImage(imageName, for: .normal)
    }
}


extension ImageListViewController: UITableViewDataSource {
    // реализуем требуемые методы протокола
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
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
//        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        showSingleImage(with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
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
}
