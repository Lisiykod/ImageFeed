//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 19.09.2024.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = .ypWhite
        button.setTitleColor(.ypBlack, for: .normal)
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var authImage: UIImageView = {
        let authImage = UIImage(named: "logo_of_unsplash")
        let image = UIImageView(image: authImage)
        return image
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViewsToSuperView()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    @objc
    private func didTapLoginButton() {
        let webViewController = WebViewViewController()
        let webViewPresenter = WebViewPresenter()
        webViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewController
        webViewController.delegate = self
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }
    
    private func addViewsToSuperView() {
        let viewArray: [UIView] = [authImage, loginButton]
        viewArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            authImage.widthAnchor.constraint(equalToConstant: 60),
            authImage.heightAnchor.constraint(equalToConstant: 60),
            authImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            guide.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: 16),
            guide.bottomAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 90)

        ])
    }
    
    private func showFailedLoginAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        var topController = UIApplication.shared.windows.first?.rootViewController
        while (topController?.presentedViewController != nil &&
               topController != topController!.presentedViewController) {
            topController = topController!.presentedViewController
        }
        topController?.present(alert, animated: true, completion: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                delegate?.didAuthenticate(self)
            case .failure:
                showFailedLoginAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
}
