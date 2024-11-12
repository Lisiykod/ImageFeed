//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 03.09.2024.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileResult(profile: Profile)
    func updateAvatar(wiht url: URL)
    func showExitAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "exit_image"), for: .normal)
        button.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
        button.tintColor = .ypRed
        return button
    }()
    
    private let userPick: UIImageView = {
        let userImage = UIImage(named: "avatar_placeholder")
        let image = UIImageView(image: userImage)
        image.backgroundColor = .ypBlack
        image.layer.cornerRadius = 61
        return image
    }()
    
    private let mainNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        initialSetup()
        addViewsToSuperView()
        setupConstraints()
        presenter?.viewDidLoad()
        // добавляем наблюдателя, что изображение получено 
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main) { [weak self] _ in
                guard let self else { return }
                self.presenter?.updateAvatar()
            }
    }
    
    deinit {
        profileImageServiceObserver = nil
    }
    
    // MARK: - Public Methods
    
    func updateAvatar(wiht url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 61, backgroundColor: .ypBlack)
        userPick.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    func updateProfileResult(profile: Profile) {
        self.mainNameLabel.text = profile.name
        self.logoLabel.text = "@" + profile.login
        self.statusLabel.text = profile.bio
    }
    
    func showExitAlert() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            buttonText: "Нет",
            secondButtonText: "Да",
            completion: nil) { [weak self] in
                guard let self else { return }
                self.presenter?.logout()
                switchToSplashController()
            }
        alertPresenter?.present(alert: alertModel)
    }

    // MARK: - Private Methods
    
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
        presenter?.didTapExitButton()
    }
    
    private func initialSetup() {
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
        
    }
    
    private func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
}
