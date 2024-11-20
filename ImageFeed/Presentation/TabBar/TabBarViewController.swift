//
//  TabBarViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 14.10.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagesListPresenter = ImagesListPresenter()
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"), selectedImage: nil)
        
        let profilePresenter = ProfilePresenter()
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        self.viewControllers = [imagesListViewController, profileViewController]
        setTabBarAppearance()
    }
    
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack
        appearance.stackedLayoutAppearance.selected.iconColor = .ypWhite
        tabBar.standardAppearance = appearance
    }
}
