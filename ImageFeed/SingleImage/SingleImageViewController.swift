//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 03.09.2024.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            guard let image = image else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        guard let image = image else { return }
        
        imageView.frame.size = image.size
        
        scrollView.maximumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Actions
    @IBAction func shareButtonTaped(_ sender: Any) {
        shareImage()
    }
    
    @IBAction func likeButtonTaped(_ sender: Any) {
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
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
        // вычисляем масштаб для горизонтальной и вертикальной осей
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
    
    // метод для показа окна "поделиться"
    private func shareImage() {
        guard let image = image else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.overrideUserInterfaceStyle = .dark
        self.present(activityController, animated: true) 
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
