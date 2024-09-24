//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 24.09.2024.
//

import UIKit

class SplashViewController: UIViewController {
    
    private let showAuthViewControllerSegueIdentifier: String = "ShowAuthenticationScreen"
    private let tabBarViewControllerIdentifier: String = "TabBarViewController"
    private let tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = tokenStorage.token {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthViewControllerSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: tabBarViewControllerIdentifier)
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthViewControllerSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController =  navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthViewControllerSegueIdentifier)")
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}
