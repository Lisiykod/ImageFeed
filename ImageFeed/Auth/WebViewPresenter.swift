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
    var authHelper: AuthHelperProtocol
//    private enum WebViewConstants {
//        static let unsplashAutorizeURLString = "https://unsplash.com/oauth/authorize"
//        static let clientID = "client_id"
//        static let redirectURI = "redirect_uri"
//        static let responseType = "response_type"
//        static let scope = "scope"
//    }
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    // метод для формирования запроса и загрузки окна авторизации
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        // обновляем значение для прогресс бара
        didUpdateProgressValue(0)
        // передаем запрос webView
        view?.load(request: request)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
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
