//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 11.11.2024.
//

import UIKit

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func logout()
    func viewDidLoad()
    func updateAvatar()
    func updateProfile() 
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    func viewDidLoad() {
        updateProfile()
        updateAvatar()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(wiht: url)
    }
    
    func updateProfile() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileResult(profile: profile)
    }
    
    func logout() {
        profileLogoutService.logout()
        switchToSplashController()
    }
    
    private func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
}
