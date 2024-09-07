//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 03.09.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private var exitButton: UIButton?
    private var mainNameLabel: UILabel?
    private var userpick: UIImageView?
    private var statusLabel: UILabel?
    private var logoLabel: UILabel?
    private var noFavoritePhotoImage: UIImageView?
    
    private var favoritesLabel: UILabel?
    // лейбл, который появится, когда настроим таблицу с избранным
    private var notificationLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setupFonts()
        setupLabels()
        addViewsToSuperView()
        setupConstraints()
    }
    
    // метод для инициализации вьюшек
    private func initViews() {
        exitButton = UIButton.systemButton(with: UIImage(named: "exit_image") ?? UIImage(), target: self, action: #selector(didTapExitButton))
        exitButton?.tintColor = .ypRed
        mainNameLabel = UILabel()
        statusLabel = UILabel()
        logoLabel = UILabel()
        let userImage = UIImage(named: "userpick_photo")
        userpick = UIImageView(image: userImage)
        favoritesLabel = UILabel()
        let noPhoto = UIImage(named: "no_photo_image")
        noFavoritePhotoImage = UIImageView(image: noPhoto)
    }
    
    // метод, в котором всех добавляем в иерархию
    private func addViewsToSuperView() {
        guard
            let exitButton = exitButton,
            let mainNameLabel = mainNameLabel,
            let statusLabel = statusLabel,
            let logoLabel = logoLabel,
            let userpick = userpick,
            let favoritesLabel = favoritesLabel,
            let noPhotoImage = noFavoritePhotoImage
        else {
            return
        }
        view.addSubview(exitButton)
        view.addSubview(mainNameLabel)
        view.addSubview(statusLabel)
        view.addSubview(logoLabel)
        view.addSubview(userpick)
        view.addSubview(favoritesLabel)
        view.addSubview(noPhotoImage)
    }
    
    // метод для настройки шрифтов
    private func setupFonts() {
        mainNameLabel?.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        mainNameLabel?.textColor = .ypWhite
        logoLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        logoLabel?.textColor = .ypGray
        statusLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusLabel?.textColor = .ypWhite
        favoritesLabel?.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        favoritesLabel?.textColor = .ypWhite
    }
    
    // метод для настройки текста в лейблах
    private func setupLabels() {
        mainNameLabel?.text = "Екатерина Новикова"
        logoLabel?.text = "@ekaterina_nov"
        statusLabel?.text = "Hello, world!"
        favoritesLabel?.text = "Избранное"
    }
    
    // метод для настройки автолейаута
    private func setupConstraints() {
        setUserPickAndExitButtonConstraints()
        setupLabelsConstraints()
        setupNoFavoritePhotoImageConstraints()
    }
    
    // метод для настройки констрейнтов изображения юзера и кнопки выход
    private func setUserPickAndExitButtonConstraints() {
        guard
            let exitButton = exitButton,
            let userpick = userpick
        else {
            return
        }
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        userpick.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userpick.widthAnchor.constraint(equalToConstant: 70),
            userpick.heightAnchor.constraint(equalToConstant: 70),
            userpick.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userpick.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: userpick.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: exitButton.trailingAnchor, constant: 12)
        ])
    }
    
    // метод для настройки констрейнтов для лейблов
    private func setupLabelsConstraints() {
        guard
            let mainNameLabel = mainNameLabel,
            let statusLabel = statusLabel,
            let logoLabel = logoLabel,
            let userpick = userpick,
            let favoritesLabel = favoritesLabel
        else {
            return
        }
        
        mainNameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainNameLabel.leadingAnchor.constraint(equalTo: userpick.leadingAnchor),
            mainNameLabel.topAnchor.constraint(equalTo: userpick.bottomAnchor, constant: 8),
            view.trailingAnchor.constraint(greaterThanOrEqualTo: mainNameLabel.trailingAnchor, constant: 124),
            logoLabel.leadingAnchor.constraint(equalTo: mainNameLabel.leadingAnchor),
            logoLabel.topAnchor.constraint(equalTo: mainNameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: mainNameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            favoritesLabel.leadingAnchor.constraint(equalTo: mainNameLabel.leadingAnchor),
            favoritesLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24)
        ])
    }
    
    // метод для настройки констрейнтов картинки "нет избранных"
    private func setupNoFavoritePhotoImageConstraints() {
        
        guard
            let favoritesLabel = favoritesLabel,
            let noPhotoImage = noFavoritePhotoImage
        else {
            return
        }
        
        noPhotoImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noPhotoImage.widthAnchor.constraint(equalToConstant: 101),
            noPhotoImage.heightAnchor.constraint(equalToConstant: 115),
            noPhotoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPhotoImage.topAnchor.constraint(lessThanOrEqualTo: favoritesLabel.bottomAnchor, constant: 103)
        ])
    }
    // метод для кнопки выход
    @objc
    private func didTapExitButton() {
        // здесь будет код
    }
    
}
