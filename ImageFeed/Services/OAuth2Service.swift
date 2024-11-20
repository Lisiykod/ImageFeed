//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 23.09.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    // переменная для хранения указателя на последнюю созданную задачу
    private var task: URLSessionTask?
    // переменная для хранения кода из последнего созданного запроса
    private var lastCode: String?
    
    // MARK: - Public Methods
    // метод для запроса токена
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        // если коды не совпадают, то делаем новый запрос
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        // старый запрос отменяем и делаем новый
        task?.cancel()
        lastCode = code
        guard
            let tokenRequest = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("invalid token request")
            return
        }
        
        let task = urlSession.objectTask(for: tokenRequest) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                let accessToken = response.accessToken
                self.storage.store(token: accessToken)
                self.task = nil
                self.lastCode = nil
                completion(.success(accessToken))
            case .failure(let error):
                print("Error in \(#file) \(#function): NetworkError - \(String(describing: error))")
                completion(.failure(error))
            }
        }
        // зафиксируем состояние таска
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private init() { }
    
    // метод для формирования запроса авторизационного токена
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)" // перечисляем параметры запроса
            + "&&client_secret=\(Constants.secretKey)" // добавляем доп параметры
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: Constants.defaultBaseURL // опираемся на базовый URL, который содержат схему и имя хоста
        )
        
        guard let url else {
            print("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        return request
    }
}
