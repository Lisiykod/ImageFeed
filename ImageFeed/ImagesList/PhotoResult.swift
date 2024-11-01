//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 01.11.2024.
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

struct Photos: Decodable {
    let photo: PhotoResult
}
