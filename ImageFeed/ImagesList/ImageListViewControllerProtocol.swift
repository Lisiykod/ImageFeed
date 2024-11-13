//
//  ImageListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 13.11.2024.
//

import Foundation

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set }
    func updateTableViewAnimated(with oldCount: Int, newCount: Int)
    func showProgressHUD()
    func hideProgressHUD()
}
