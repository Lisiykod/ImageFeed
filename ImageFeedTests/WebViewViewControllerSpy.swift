//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Olga Trofimova on 10.11.2024.
//

import Foundation
import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressIsHidden(_ isHidden: Bool) {
        
    }
    
    
}
