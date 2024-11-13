//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Olga Trofimova on 12.11.2024.
//

import Foundation
import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func logout() { }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapExitButton() { }
    
    func updateAvatar() { }
    
    func updateProfile() { }
    
}
