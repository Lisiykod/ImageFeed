//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 24.10.2024.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let likedByUser: Bool
    let urls: UrlsResult
    let description: String?
}

struct UrlsResult: Decodable {
    let full: String
    let thumb: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImageListService {
    static let shared = ImageListService()
    static let didChangeNotification = Notification.Name("ImageListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter = DateFormatter()
    private let storage = OAuth2TokenStorage()
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        assert(Thread.isMainThread)
        
        guard task == nil else {
            print("retry fetch")
            return
        }
        
        guard let photosRequest = makePhotosRequest(page: nextPage) else {
            print("invalid photos request")
            return
        }
        
        let task = urlSession.objectTask(for: photosRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photos):
                photos.forEach { photo in
                    self.photos.append(self.convert(result: photo))
                }
                NotificationCenter.default.post(
                    name: ImageListService.didChangeNotification,
                    object: self
                )
                lastLoadedPage = nextPage
                self.task = nil
                print("Photos count: \(photos.count)")
            case .failure(let error):
                print("Error in \(#file) \(#function): NetworkError - \(String(describing: error))")
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private init() {}
    
    private func makePhotosRequest(page: Int) -> URLRequest? {
        let authToken = storage.token
        guard let authToken else {
            print("invalid auth token")
            return nil
        }
        let baseURL = URL(string: "https://api.unsplash.com")
        let url = URL(string: "/photos/"
                      + "?page=\(page)",
                      relativeTo: baseURL)
        guard let url else {
            print("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    private func convert(result data: PhotoResult) -> Photo {
        let photo = Photo(
            id: data.id,
            size: CGSize(width: data.width, height: data.height),
            createdAt: dateFormatter.date(from: data.createdAt),
            welcomeDescription: data.description,
            thumbImageURL: data.urls.thumb,
            largeImageURL: data.urls.full,
            isLiked: data.likedByUser
        )
        return photo
    }
}
