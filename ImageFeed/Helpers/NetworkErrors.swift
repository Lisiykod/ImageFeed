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
                print("[Network errors] - failure status code: \(code)")
            case .urlRequestError(let requestError):
                print("[Network errors] - failed request: \(requestError)")
            case .urlSessionError:
                print("[Network errors] - session unknown error")
            }
        } else {
            print("[Network errors] - unknown error: \(error.localizedDescription)")
        }
    }
}
