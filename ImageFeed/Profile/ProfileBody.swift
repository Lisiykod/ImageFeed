//
//  ProfileBody.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 06.10.2024.
//

import Foundation

struct ProfileBody: Decodable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}
