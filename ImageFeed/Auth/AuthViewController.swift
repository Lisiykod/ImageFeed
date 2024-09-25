//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 19.09.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    @IBOutlet private var logInButton: UIButton!
    
    private let showingWebViewSegueIdentifier: String = "ShowWebView"
    private let oauth2Service: OAuth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
    }
    
    // MARK: - Public Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showingWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                fatalError("Failed to prepare for \(showingWebViewSegueIdentifier)")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    private func setupLoginButton() {
        logInButton.layer.cornerRadius = 16
        logInButton.layer.masksToBounds = true
        logInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
            oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    delegate?.didAuthenticate(self)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
