//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 24.09.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let storage = KeychainWrapper.standard
    
    private(set) var token: String? {
        get {
            storage.string(forKey: "accessKey")
        }
        set {
            guard let newValue else {
                print("failed token value")
                return
            }
            storage.set(newValue, forKey: "accessKey")
        }
    }
    
    func store(token: String) {
        self.token = token
    }
    
    func removeToken() {
        storage.removeObject(forKey: "accessKey")
    }
}
