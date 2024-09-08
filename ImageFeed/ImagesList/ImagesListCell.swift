//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 31.08.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private var mainImage: UIImageView!
    @IBOutlet private var favoriteImage: UIButton!
    @IBOutlet private var gradientView: UIView!
    @IBOutlet private var dateLabel: UILabel!
    
    private let gradientLayer = CAGradientLayer()
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: self.layer)
        // настраиваем область показа градиента, чтобы он не обрезался
        gradientLayer.frame = gradientView.bounds
    }
    
    override func awakeFromNib() {
        setCellGradient()
    }
    
    // метод для настройки ячейки
    func configCell(with date: DateFormatter, image: UIImage, indexPath: IndexPath) {
        // настраиваем картинку
        mainImage.image = image
        mainImage.layer.cornerRadius = 16
        mainImage.layer.masksToBounds = true

        // настраиваем дату
        dateLabel.text = date.string(from: Date())
        // настраиваем лайк
        let isFavorite = indexPath.row % 2 == 0
        let imageName = isFavorite ? UIImage(named: "favorite") : UIImage(named: "not_favorite")
        favoriteImage.setImage(imageName, for: .normal)
    }
    
    // метод для настройки градиента
    func setCellGradient() {
        
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        // настраиваем цвета
        let colorOne = UIColor.ypBlack.withAlphaComponent(0.0).cgColor
        let colorTwo = UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        gradientLayer.colors = [colorOne, colorTwo]
        // добавляем слой с градиентом
        gradientView.layer.addSublayer(gradientLayer)
    }
    
}

