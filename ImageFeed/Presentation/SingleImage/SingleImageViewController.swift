//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 03.09.2024.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL?
    private var alertPresenter: AlertPresenterProtocol?
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            guard let image = image else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        return scrollView
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "sharing_button"), for: .normal)
        button.addTarget(self, action: #selector(shareButtonTaped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "backward_image"), for: .normal)
        button.accessibilityIdentifier = "Back button"
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .ypBlack
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        imageView.image = image
        addViewsToSuperview()
        setupConstraints()
        initialSetup()
        
        guard let imageURL else { return }
        loadImage(with: imageURL)
    }
    
    
    // MARK: - Private Methods
    
    @objc 
    private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // метод для показа окна "поделиться"
    @objc
    private func shareButtonTaped() {
        guard let image = image else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.overrideUserInterfaceStyle = .dark
        self.present(activityController, animated: true)
    }
    
    private func addViewsToSuperview() {
        scrollView.addSubview(imageView)
        let viewArray: [UIView] = [scrollView, shareButton, backButton]
        viewArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            
            shareButton.widthAnchor.constraint(equalToConstant: 51),
            shareButton.heightAnchor.constraint(equalToConstant: 51),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.bottomAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 50)
        ])
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // учитываем диапазон зума
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        // сразу же пересчитываем лейаут
        view.layoutIfNeeded()
        // определяем размеры изображения
        let imageSize = image.size
        // определяем видимую область
        let visibleRectSize = scrollView.bounds.size
        // вычисляем масштаб для горизонтальной и вертикальной оси
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        // вычисляем минимальное значение, чтобы изображение растягивалось с сохр пропорций
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        // устанавливаем полученный масштаб
        // (здесь contentSize не меняется мгновенно)
        scrollView.setZoomScale(scale, animated: false)
        // поэтому снова сразу пересчитываем лейаут и актуализируем contentSize
        scrollView.layoutIfNeeded()
        // вычисляем центр
        let newContentSize = scrollView.contentSize
        // расчитываем координаты для смещения
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        // устанавливаем новую точку
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // метод для центрирования изображения после зума
    private func centerImage() {
        let boundsSize = scrollView.bounds.size
        var imageFrame = imageView.frame
        
        if imageFrame.width < boundsSize.width {
            imageFrame.origin.x = (boundsSize.width - imageFrame.width) / 2
        }
        
        if imageFrame.height < boundsSize.height {
            imageFrame.origin.y = (boundsSize.height - imageFrame.height) / 2
        }
    }
    
    // метод для загрузки изображения
    private func loadImage(with largeImageURL: URL) {
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: largeImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
                guard let image else { return }
                self.imageView.frame.size = image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так",
            message: "Поробовать еще раз",
            buttonText: "Не надо",
            secondButtonText: "Попробовать еще раз", secondCompletion: { [weak self] in
                guard let imageURL = self?.imageURL else { return }
                self?.loadImage(with: imageURL)
            })
        alertPresenter?.present(alert: alertModel)
    }
    
    private func initialSetup() {
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
