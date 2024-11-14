//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 12.11.2024.
//

import Foundation

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileResult(profile: Profile)
    func updateAvatar(wiht url: URL)
    func showExitAlert()
}
