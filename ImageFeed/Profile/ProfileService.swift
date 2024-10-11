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

struct Profile {
    let name: String
    let login: String
    let bio: String
    
    init(profileInfo: ProfileBody) {
        self.name = (profileInfo.firstName ?? "") + " " + (profileInfo.lastName ?? "")
        self.login = profileInfo.username
        self.bio = profileInfo.bio ?? ""
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let profileRequest = makeProfileInfoRequest(with: token)
        else {
            completion(.failure(ProfileServiceError.invalidRequest))
            print("invalid profile request")
            return
        }
        
        let task = urlSession.objectTask(for: profileRequest) { (result: Result<ProfileBody, Error>) in
            switch result {
            case .success(let profile):
                self.profile = Profile(profileInfo: profile)
                guard let profile = self.profile else { return }
                completion(.success(profile))
                self.task = nil
            case .failure(let error):
                print("[ProfileService.fetchProfile]: NetworkError - \(String(describing: error))")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    //MARK: - Private Methods
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
