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
    let medium: String
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String,_ token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let profileImageRequest = makeProfileImageRequest(with: token, username: username)
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            print("invalid profile request")
            return
        }
        
        let task = urlSession.objectTask(for: profileImageRequest) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let user):
                self.avatarURL = user.profileImage.medium
                guard let avatarURL = self.avatarURL else { return }
                completion(.success(avatarURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL])
                self.task = nil
            case .failure(let error):
                print("Error in \(#file) \(#function): NetworkError - \(String(describing: error))")
            }
        }
        self.task = task
        task.resume()
        
    }
    
    func cleanAvatar() {
        avatarURL = nil
    }
    
    //MARK: - Private Methods
    private init() {}
    
    private func makeProfileImageRequest(with authToken: String, username: String) -> URLRequest? {
        let baseURL = URL(string: "https://api.unsplash.com")
        let url = URL(string: "/users/\(username)", relativeTo: baseURL)
        
        guard let url else {
            print("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
