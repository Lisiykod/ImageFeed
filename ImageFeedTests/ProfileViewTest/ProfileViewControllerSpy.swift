//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Olga Trofimova on 12.11.2024.
//

import Foundation
import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var showExitAlertCalled: Bool = false
    var updateAvararCalled: Bool = false
    
    func updateProfileResult(profile: ImageFeed.Profile) { }
    
    func updateAvatar(wiht url: URL) {
        updateAvararCalled = true
    }
    
    func showExitAlert() {
        showExitAlertCalled = true
    }
    
    
}
