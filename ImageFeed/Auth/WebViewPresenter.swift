//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 09.11.2024.
//

import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? {get set}
    func viewDidLoad()
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    private enum WebViewConstants {
        static let unsplashAutorizeURLString = "https://unsplash.com/oauth/authorize"
        static let clientID = "client_id"
        static let redirectURI = "redirect_uri"
        static let responseType = "response_type"
        static let scope = "scope"
    }
    
    // метод для формирования запроса и загрузки окна авторизации
    func viewDidLoad() {
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
        view?.load(request: request)
    }
}
