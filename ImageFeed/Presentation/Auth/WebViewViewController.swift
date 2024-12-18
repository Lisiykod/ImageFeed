//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 20.09.2024.
//

import UIKit
@preconcurrency import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? {get set}
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressIsHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    private let tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage()
    private var estimatedProgressObservation: NSKeyValueObservation?
    private var alertPresenter: AlertPresenterProtocol?
    
    private var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .ypWhite
        webView.accessibilityIdentifier = "UnsplashWebView"
        return webView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"nav_back_button"), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .ypBlack
        return progressView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addViewsToSuperView()
        setupConstraints()
        initialSetup()
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.didUpdateProgressValue(webView.estimatedProgress)
    }
    
    // MARK: - Public Methods
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.setProgress(newValue, animated: true)
    }
    
    func setProgressIsHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    // MARK: - Private Methods
    @objc
    private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    private func addViewsToSuperView() {
        let viewsArray: [UIView] = [webView, backButton, progressView]
        viewsArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.topAnchor.constraint(equalTo: guide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: webView.bottomAnchor)
        ])
    }
    
    // метод для возврата кода авторизации (если получен)
    private func code(from navigationAction: WKNavigationAction) -> String? {
        // получаем url
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
    
}

extension WebViewViewController: WKNavigationDelegate {
    // метод благодаря которому узнаем, что пользователь успешно авторизовался
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // проверяем получен ли код авторизации
        if let code = code(from: navigationAction) {
            // обрабатываем код
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            // отменяем навигационное действие, т.к сделано все, что нужно
            decisionHandler(.cancel)
        } else {
            // разрешаем переход, чтобы была возможность перейти на новую стр (возможно в рамках авторизации)
            decisionHandler(.allow)
        }
    }
}

extension WebViewViewController: AlertPresenterDelegate {
    func showFailedLoginAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "OK",
            completion: { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
            })
        alertPresenter?.present(alert: alertModel)
    }
    
    private func initialSetup() {
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
    }
}
