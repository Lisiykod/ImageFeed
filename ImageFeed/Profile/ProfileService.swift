//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 06.10.2024.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    struct Profile {
        let name: String
        let login: String
        let bio: String
        
        init(profileInfo: ProfileBody) {
            self.name = (profileInfo.firstName ?? "") + " " + (profileInfo.lastName ?? "")
            self.login = "@" + profileInfo.username
            self.bio = profileInfo.bio ?? ""
        }
    }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let profileRequest = makeProfileInfoRequest(with: token)
        else {
            completion(.failure(ProfileServiceError.invalidRequest))
            print("invalid profile request")
            return
        }
        
        let task = urlSession.data(for: profileRequest) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(ProfileBody.self, from: data)
                    let profile = Profile(profileInfo: response)
                    completion(.success(profile))
                    self.task = nil
                } catch {
                    print("data profile error: \(String(describing: error))")
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
        self.task = task
        task.resume()
    }
    private init() { }
    
    private func makeProfileInfoRequest(with authToken: String) -> URLRequest? {
        let baseURL = URL(string: "https://api.unsplash.com")
        let url = URL(string: "/me", relativeTo: baseURL)
        
        guard let url else {
            assertionFailure("Failed to create URL")
            print("invalid url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
