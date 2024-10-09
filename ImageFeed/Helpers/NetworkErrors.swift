//
//  NetworkErrors.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 08.10.2024.
//

import Foundation

final class NetworkErrors {
    static let shared = NetworkErrors()
    
    private init() {}
    
    func errors(_ error: Error) {
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
    }
}
