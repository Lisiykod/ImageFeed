//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 08.10.2024.
//

import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
}

struct UserResult: Codable {
    let profileImage: ImageSize
}

struct ImageSize: Codable {
    let small: String
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String,_ token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let profileImageRequest = makeProfileImageRequest(with: token, username: username)
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            print("invalid profile request")
            return
        }
        
        let task = urlSession.data(for: profileImageRequest) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(UserResult.self, from: data)
                    self.avatarURL = response.profileImage.small
                    print(avatarURL ?? "not image")
                    guard let avatarURL = self.avatarURL else { return }
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                    self.task = nil
                } catch {
                    print("data profile error: \(String(describing: error))")
                    completion(.failure(error))
                }
            case .failure(let error):
                NetworkErrors.shared.errors(error)
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
        
    }
    
    //MARK: - Private Methods
    private init() {}
    
    private func makeProfileImageRequest(with authToken: String, username: String) -> URLRequest? {
        let baseURL = URL(string: "https://api.unsplash.com")
//        https://api.unsplash.com/users/airlis
        let url = URL(string: "/users/\(username)", relativeTo: baseURL)
//        let url = URL(string: "https://api.unsplash.com/users/airlis")
        print("url: \(url)")
        
        guard let url else {
            assertionFailure("Failed to create URL")
            print("invalid url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print("request url: \(String(describing: request))")
        return request
    }
}
