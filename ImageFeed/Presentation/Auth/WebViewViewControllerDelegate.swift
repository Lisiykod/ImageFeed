//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 21.09.2024.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
