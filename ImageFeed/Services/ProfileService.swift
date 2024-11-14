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
    private(set) var profile: Profile?
    

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let profileRequest = makeProfileInfoRequest(with: token)
        else {
            completion(.failure(ProfileServiceError.invalidRequest))
            print("invalid profile request")
            return
        }
        
        let task = urlSession.objectTask(for: profileRequest) { [weak self] (result: Result<ProfileBody, Error>) in
            guard let self else { return }
            switch result {
            case .success(let profile):
                self.profile = Profile(profileInfo: profile)
                guard let profile = self.profile else { return }
                completion(.success(profile))
                self.task = nil
            case .failure(let error):
                print("Error in \(#file) \(#function): NetworkError - \(String(describing: error))")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    func cleanProfile() {
        profile = nil
    }
    
    //MARK: - Private Methods
    private init() { }
    
    private func makeProfileInfoRequest(with authToken: String) -> URLRequest? {
        let baseURL = URL(string: "https://api.unsplash.com")
        let url = URL(string: "/me", relativeTo: baseURL)
        
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
