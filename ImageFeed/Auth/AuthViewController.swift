//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 19.09.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    
    @IBOutlet private var logInButton: UIButton!
    
    private let showingWebViewSegueIdentifier: String = "ShowWebView"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.layer.cornerRadius = 16
        logInButton.layer.masksToBounds = true
        configureBackButton()
    }
    
    // MARK: - Private Methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        // настраиваем маску для корректного отображения анимации
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
}
