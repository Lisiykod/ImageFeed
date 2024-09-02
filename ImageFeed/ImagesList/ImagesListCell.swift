//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 31.08.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var favoriteImage: UIButton!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var dateLabel: UILabel!
    
    private let gradientLayer = CAGradientLayer()
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: self.layer)
        // добавляем вью с градиентом, чтобы обрезались границы
        mainImage.addSubview(gradientView)
        // настраиваем область градиента
        gradientLayer.frame = gradientView.bounds
        // настраиваем цвета
        let colorOne = UIColor.ypBlack.withAlphaComponent(0).cgColor
        let colorTwo = UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        gradientLayer.colors = [colorOne, colorTwo]
        // добавляем слой с градиентом
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

