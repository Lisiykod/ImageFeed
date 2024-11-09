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
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
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
        // обновляем значение для прогресс бара
        didUpdateProgressValue(0)
        // передаем запрос webView
        view?.load(request: request)
    }
    
    func code(from url: URL) -> String? {
        if
            // получаем значения компонентов
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
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressIsHidden(shouldHideProgress)
    }
    
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
