//
//  Profile.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 01.11.2024.
//

import Foundation

public struct Profile {
    let name: String
    let login: String
    let bio: String
    
    init(profileInfo: ProfileBody) {
        self.name = (profileInfo.firstName ?? "") + " " + (profileInfo.lastName ?? "")
        self.login = profileInfo.username
        self.bio = profileInfo.bio ?? ""
    }
}
