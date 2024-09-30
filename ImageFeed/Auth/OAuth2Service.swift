//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 23.09.2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Public Methods
    // метод для запроса токена
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let tokenRequest = makeOAuthTokenRequest(code: code)
        guard let tokenRequest else {
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
                } catch {
                    print("data decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case.failure(let error):
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
            print("invalid url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
