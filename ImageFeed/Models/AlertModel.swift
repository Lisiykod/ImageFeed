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
    let completion:(() -> Void)?
    let secondCompletion: (() -> Void)?
    
    init(title: String, message: String, buttonText: String, secondButtonText: String? = nil, completion: (() -> Void)? = nil, secondCompletion: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.secondButtonText = secondButtonText
        self.completion = completion
        self.secondCompletion = secondCompletion
    }
}
