//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 23.09.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() { }
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            preconditionFailure("not base url")
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
        guard let url = url else {
            preconditionFailure("invalid url")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<Data, Error>) -> Void) {
        let tokenRequest = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.dataTask(with: tokenRequest) { data, response, error in
            if let error = error {
                handler(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
            }
            
            guard let data = data else { return }
            handler(.success(data))
            
        }
        task.resume()
    }
}
