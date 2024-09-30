//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 20.09.2024.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    private enum WebViewConstants {
        static let unsplashAutorizeURLString = "https://unsplash.com/oauth/authorize"
        static let clientID = "client_id"
        static let redirectURI = "redirect_uri"
        static let responseType = "response_type"
        static let scope = "scope"
    }
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    private let tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        updateProgress()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private Methods
    // метод для загрузки окна авторизации
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAutorizeURLString) else {
            return
        }
        // значения компонентов, которые мы хотим передать в запросе
        urlComponents.queryItems = [
            URLQueryItem(name: WebViewConstants.clientID, value: Constants.accessKey),
            URLQueryItem(name: WebViewConstants.redirectURI, value: Constants.redirectURI),
            URLQueryItem(name: WebViewConstants.responseType, value: "code"),
            URLQueryItem(name: WebViewConstants.scope, value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        // передаем запрос webView
        webView.load(request)
    }
    
    // метод для возврата кода авторизации (если получен)
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            // получаем url
            let url = navigationAction.request.url,
            // получаем из него значения компонентов
            let urlComponents = URLComponents(string: url.absoluteString),
            // проверяем совпадает ли адрес запроса с адресом получением кода
            urlComponents.path == "/oauth/authorize/native",
            // проверяем есть ли компоненты запроса
            let items = urlComponents.queryItems,
            // провреяем есть ли "code"
            let codeItem = items.first(where: {$0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
