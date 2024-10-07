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
        assert(Thread.isMainThread)
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

        let task = URLSession.shared.data(for: tokenRequest) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let accessToken = response.accessToken
                    self.storage.store(token: accessToken)
                    completion(.success(accessToken))
                    // обнуляем таск, вдруг возможно состояние гонки
                    self.task = nil
                    self.lastCode = nil
                } catch {
                    print("data decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let error = error as? NetworkError {
                    switch error {
                    case .httpStatusCode(let code):
                        print("failure status code: \(code)")
                    case .urlRequestError(let requestError):
                        print("failed request: \(requestError)")
                    case .urlSessionError:
                        print("session unknown error")
                    }
                } else {
                    print("unknown error: \(error.localizedDescription)")
                }
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
        guard let baseURL = Constants.defaultBaseURL else {
            print("not base url")
            return nil
        }
        
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)" // перечисляем параметры запроса
            + "&&client_secret=\(Constants.secretKey)" // добавляем доп параметры
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL // опираемся на базовый URL, которые содержат схему и имя хоста
        )
        
        guard let url else {
            assertionFailure("Failed to create URL")
            print("invalid url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
