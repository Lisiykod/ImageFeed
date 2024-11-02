//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 03.09.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileLogoutService = ProfileLogoutService.shared
    private let gradient: CAGradientLayer = CAGradientLayer()
    private var animationLayers: Set<CALayer> = Set<CALayer>()
    private var gradientsLayers: Set<CAGradientLayer> = Set<CAGradientLayer>()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "exit_image"), for: .normal)
        button.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
        button.tintColor = .ypRed
        return button
    }()
    
    private let userPick: UIImageView = {
        let userImage = UIImage(named: "userpick_photo")
        let image = UIImageView(image: userImage)
        image.backgroundColor = .ypBlack
        image.layer.cornerRadius = 61
        return image
    }()
    
    private let mainNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        label.text = "Екатерина Новикова"
        label.numberOfLines = 0
        print("label \(label)")
        return label
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        label.text = "@ekaterina_nov"
        label.numberOfLines = 0
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.text = "Hello, world!"
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViewsToSuperView()
        setupConstraints()
        setupAvatarGradient()
        setupMainNameLabelGradient()
        setupLogoLabelGradient()
        setupStatusLabelGradient()
        guard let profile = profileService.profile else { return }
        updateProfileResult(profile: profile)
        // добавляем наблюдателя, что изображение получено 
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main) { [weak self] _ in
                guard let self else { return }
//                self.gradientsLayers.removeFromSuperlayer()
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    deinit {
        profileImageServiceObserver = nil
    }
    
    // метод, в котором всех добавляем в иерархию
    private func addViewsToSuperView() {
        let viewsArray: [UIView] = [exitButton, userPick, mainNameLabel, logoLabel, statusLabel]
        viewsArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    // метод для настройки автолейаута
    private func setupConstraints() {
        setUserPickAndExitButtonConstraints()
        setupLabelsConstraints()
    }
    
    // метод для настройки констрейнтов изображения юзера и кнопки выход
    private func setUserPickAndExitButtonConstraints() {
        NSLayoutConstraint.activate([
            userPick.widthAnchor.constraint(equalToConstant: 70),
            userPick.heightAnchor.constraint(equalToConstant: 70),
            userPick.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userPick.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: userPick.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: exitButton.trailingAnchor, constant: 12)
        ])
    }
    
    // метод для настройки констрейнтов для лейблов
    private func setupLabelsConstraints() {
        NSLayoutConstraint.activate([
            mainNameLabel.leadingAnchor.constraint(equalTo: userPick.leadingAnchor),
            mainNameLabel.topAnchor.constraint(equalTo: userPick.bottomAnchor, constant: 8),
            view.trailingAnchor.constraint(greaterThanOrEqualTo: mainNameLabel.trailingAnchor, constant: 16),
            logoLabel.leadingAnchor.constraint(equalTo: mainNameLabel.leadingAnchor),
            logoLabel.topAnchor.constraint(equalTo: mainNameLabel.bottomAnchor, constant: 8),
            view.trailingAnchor.constraint(greaterThanOrEqualTo: logoLabel.trailingAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: mainNameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            view.trailingAnchor.constraint(greaterThanOrEqualTo: statusLabel.trailingAnchor, constant: 16)
        ])
    }
    
    // метод для кнопки выход
    @objc
    private func didTapExitButton() {
        profileLogoutService.logout()
        switchToSplashController()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 61, backgroundColor: .ypBlack)
        userPick.kf.setImage(with: url, options: [.processor(processor)])
        removeGradients()
    }
    
    private func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    private func updateProfileResult(profile: Profile) {
        self.mainNameLabel.text = profile.name
        self.logoLabel.text = "@" + profile.login
        self.statusLabel.text = profile.bio
    }
    
    private func animation(gradient: CAGradientLayer) {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    private func setupAvatarGradient() {
        var avatarGradient = CAGradientLayer()
        avatarGradient = gradient.setImagesGradient()
        avatarGradient.frame = CGRect(origin:.zero, size: CGSize(width: userPick.frame.width, height: userPick.frame.height))
        avatarGradient.cornerRadius = 35
        avatarGradient.masksToBounds = true
        userPick.layer.addSublayer(avatarGradient)
        animationLayers.insert(avatarGradient)
        gradientsLayers.insert(avatarGradient)
        animation(gradient: avatarGradient)
    }
    
    private func setupMainNameLabelGradient() {
        var mainLabelGradient = CAGradientLayer()
        mainLabelGradient = gradient.setImagesGradient()
        mainLabelGradient.frame = CGRect(origin:.zero, size: CGSize(width: 223, height: 28))
        print("label frame - \(mainLabelGradient.frame)")
        mainLabelGradient.cornerRadius = 9
        mainLabelGradient.masksToBounds = true
        mainNameLabel.layer.addSublayer(mainLabelGradient)
        animationLayers.insert(mainLabelGradient)
        gradientsLayers.insert(mainLabelGradient)
        animation(gradient: mainLabelGradient)
    }
    
    private func setupLogoLabelGradient() {
        var logoLabelGradient = CAGradientLayer()
        logoLabelGradient = gradient.setImagesGradient()
        logoLabelGradient.frame = CGRect(origin:.zero, size: CGSize(width: 89, height: 18))
        print("label frame - \(logoLabelGradient.frame)")
        logoLabelGradient.cornerRadius = 9
        logoLabelGradient.masksToBounds = true
        logoLabel.layer.addSublayer(logoLabelGradient)
        animationLayers.insert(logoLabelGradient)
        gradientsLayers.insert(logoLabelGradient)
        animation(gradient: logoLabelGradient)
    }
    
    private func setupStatusLabelGradient() {
        var statusLabelGradient = CAGradientLayer()
        statusLabelGradient = gradient.setImagesGradient()
        statusLabelGradient.frame = CGRect(origin:.zero, size: CGSize(width: 67, height: 18))
        print("label frame - \(statusLabelGradient.frame)")
        statusLabelGradient.cornerRadius = 9
        statusLabelGradient.masksToBounds = true
        statusLabel.layer.addSublayer(statusLabelGradient)
        animationLayers.insert(statusLabelGradient)
        gradientsLayers.insert(statusLabelGradient)
        animation(gradient: statusLabelGradient)
    }
    
    private func removeGradients() {
        print("gradientsLayers - \(gradientsLayers.count)")
        gradientsLayers.forEach { gradient in
            gradient.removeFromSuperlayer()
        }
    }
}

extension CAGradientLayer {
    func setImagesGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
                UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
                UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        return gradient
    }
}
