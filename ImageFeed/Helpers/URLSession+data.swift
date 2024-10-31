//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 23.09.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        // чтобы вывести все на главный поток
        let fullfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    // возвращаем успешный результат
                    fullfillCompletionOnTheMainThread(.success(data))
                } else {
                    // возвращаем ошибку из-за неблагоприятного диапазона статуса
                    fullfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fullfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fullfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        
        return task
    }
    
    func objectTask<T:Decodable>(
        for request: URLRequest,
        completion: @escaping (Result <T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("\(#file) \(#function) - data decoding error: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                NetworkErrors.shared.errors(error)
                completion(.failure(error))
            }
        }
        
        return task
    }
}
