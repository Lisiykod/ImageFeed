//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 24.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let tokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private var profileIsFethced: Bool = false
    
    private lazy var splashScreenImage: UIImageView = {
        let splashImage = UIImage(named: "launch_image")
        let image = UIImageView(image: splashImage)
        return image
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViewToSuperView()
        setupSplashViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = tokenStorage.token {
            if !profileIsFethced {
                fetchProfile(token)
            }
        } else {
            showAuthViewController()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = TabBarViewController()
        window.rootViewController = tabBarController
    }
    
    private func addViewToSuperView() {
        view.addSubview(splashScreenImage)
    }
    
    private func setupSplashViewController() {
        view.backgroundColor = .ypBlack
        
        splashScreenImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splashScreenImage.widthAnchor.constraint(equalToConstant: 75),
            splashScreenImage.heightAnchor.constraint(equalToConstant: 77),
            splashScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: false)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        guard let token = tokenStorage.token else {
            return
        }
        fetchProfile(token)
        profileIsFethced = true
        vc.dismiss(animated: true)
    }
    
    private func fetchProfile(_ token: String) {
        
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                switchToTabBarController()
                ProfileImageService.shared.fetchProfileImageURL(username: profile.login, token) { _ in }
            case .failure(let error):
                print("[Profile service error] - \(error.localizedDescription)")
                break
            }
        }
    }
}
