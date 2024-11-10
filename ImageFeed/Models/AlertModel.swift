//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 11.11.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let secondButtonText: String?
    let completion: (() -> Void)?
    let secondCompletion: (() -> Void)?
}
