//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 20.09.2024.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    enum WebViewConstants {
        static let unsplashAutorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    @IBOutlet private var webView: WKWebView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    // метод для закрузки окна авторизации
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAutorizeURLString) else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // метод для возврата кода авторизации (если получен)
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            // получаем url
            let url = navigationAction.request.url,
            // получаем из него значения компонентов
            let urlComponents = URLComponents(string: url.absoluteString),
            // проверяем совпадает ли адрес с получением кода
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
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            // TODO: process code
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
