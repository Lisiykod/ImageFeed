//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 11.11.2024.
//

import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func updateProfile()
    func didTapExitButton()
    func logout()
    
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
    
    func didTapExitButton() {
        view?.showExitAlert()
    }
    
    func logout() {
        profileLogoutService.logout()
    }
    
}
