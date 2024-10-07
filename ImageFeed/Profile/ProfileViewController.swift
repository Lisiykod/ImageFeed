//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 03.09.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
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
        return image
    }()
    
    private let mainNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        label.text = "Екатерина Новикова"
        label.numberOfLines = 0
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
        addViewsToSuperView()
        setupConstraints()
        guard let authToken = tokenStorage.token else {
            print("not token in storage")
            return
        }
        profileService.fetchProfile(authToken) { result in
            switch result {
            case .success(let data):
                self.mainNameLabel.text = data.name
                self.logoLabel.text = data.login
                self.statusLabel.text = data.bio
            case .failure(let error):
                print(error)
            }
        }
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
        tokenStorage.removeToken()
        switchToSplashController()
    }
    
    private func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController")
        window.rootViewController = splashViewController
    }
}
