//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 24.09.2024.
//

import Foundation

final class OAuth2TokenStorage {
    private let storage = UserDefaults.standard
    
    private var token: String? {
        get {
            storage.string(forKey: "accessKey")
        }
        set {
            storage.set(newValue, forKey: "accessKey")
        }
    }
    
    func store(token: String) {
        self.token = token
    }
}
