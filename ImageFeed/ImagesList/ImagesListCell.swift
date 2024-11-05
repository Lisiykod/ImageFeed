//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 31.08.2024.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    lazy var mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var favoriteImageButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
        return button
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var gradientView: UIView = {
        let gradientView = UIView()
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        // настраиваем цвета
        let colorOne = UIColor.ypBlack.withAlphaComponent(0.0).cgColor
        let colorTwo = UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        gradientLayer.colors = [colorOne, colorTwo]
        // добавляем слой с градиентом
        gradientView.layer.addSublayer(gradientLayer)
        return gradientView
    }()
    
    private let gradientLayer = CAGradientLayer()
    private var cellGradientLayer = CAGradientLayer()
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: self.layer)
        // настраиваем область показа градиента, чтобы он не обрезался
        gradientLayer.frame = gradientView.bounds
        cellGradientLayer.frame = CGRect(x: 16, y: 4, width: mainImage.bounds.width, height: mainImage.bounds.height)
    }
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // настраиваем фон
        backgroundColor = .ypBlack
        selectionStyle = .none
        // настраиваем все остальное
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage.kf.cancelDownloadTask()
        mainImage.image = nil
        dateLabel.text = nil
        favoriteImageButton.setImage(UIImage(named: "not_favorite"), for: .normal)
//        removeAnimation()
    }
    
    // MARK: - Public Methods
    
    func setIsLiked(_ isFavorite: Bool) {
        let imageName = isFavorite ? UIImage(named: "favorite") : UIImage(named: "not_favorite")
        favoriteImageButton.setImage(imageName, for: .normal)
    }
    
    func animationGradient() {
        setCellGradientLayer()
        animation()
    }
    
    func removeAnimation() {
        gradientLayer.removeFromSuperlayer()
    }
    
    // MARK: - Private Methods
    
    private func setupCell() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        self.contentView.addSubview(mainImage)
        self.contentView.addSubview(favoriteImageButton)
        mainImage.addSubview(gradientView)
        gradientView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        setMainImageConstraints()
        setFavoriteImageButtonConstraints()
        setGradienViewAndDataLabelConstraints()
    }
    
    private func setMainImageConstraints() {
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: 16),
            mainImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            contentView.bottomAnchor.constraint(equalTo: mainImage.bottomAnchor, constant: 4)
        ])
    }
    
    private func setFavoriteImageButtonConstraints() {
        favoriteImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favoriteImageButton.heightAnchor.constraint(equalToConstant: 44),
            favoriteImageButton.widthAnchor.constraint(equalToConstant: 44),
            contentView.trailingAnchor.constraint(equalTo: favoriteImageButton.trailingAnchor, constant: 16),
            favoriteImageButton.topAnchor.constraint(equalTo: mainImage.topAnchor)
        ])
    }
    
    private func setGradienViewAndDataLabelConstraints() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.leadingAnchor.constraint(equalTo: mainImage.leadingAnchor),
            mainImage.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            mainImage.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 8),
            dateLabel.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(greaterThanOrEqualTo: gradientView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8)
            
        ])
    }
    
   private func setCellGradientLayer() {
        let gradient = CAGradientLayer().setImagesGradient()
        cellGradientLayer = gradient
        cellGradientLayer.cornerRadius = 16
        cellGradientLayer.masksToBounds = true
        contentView.layer.addSublayer(cellGradientLayer)
    }
    
    private func animation() {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        cellGradientLayer.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    @objc
    private func didTapFavoriteButton() {
        delegate?.imageListCellDidTapLike(self)
    }
}

