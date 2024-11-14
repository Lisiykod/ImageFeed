//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 30.10.2024.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    private let profileImageService = ProfileImageService.shared
    private let imageListService = ImageListService.shared
    
    func logout() {
        cleanProfileData()
        cleanCookies()
    }
    
    private init() {}
    
    private func cleanProfileData() {
        // очищаем токен и данные профайла с лентой
        tokenStorage.removeToken()
        profileService.cleanProfile()
        profileImageService.cleanAvatar()
        imageListService.cleanPhotos()
    }
    
    private func cleanCookies() {
        // Очищаем куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // массив полученных данных удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
