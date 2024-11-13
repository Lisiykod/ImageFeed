//
//  ImagesListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 13.11.2024.
//

import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(with oldCount: Int, newCount: Int)
    func showProgressHUD()
    func hideProgressHUD()
}
