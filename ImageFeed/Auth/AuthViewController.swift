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
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
