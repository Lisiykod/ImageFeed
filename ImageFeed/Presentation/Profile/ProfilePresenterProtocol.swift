//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 12.11.2024.
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
