//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 10.11.2024.
//

import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func present(alert: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol {
    
    private weak var delegate: UIViewController?
    
    func present(alert: AlertModel) {
        let alertModel = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: alert.buttonText, style: .default) { _ in
            alert.completion?()
        }
        alertModel.addAction(action)
        
        if let secondButtonText = alert.secondButtonText {
            let secondAction = UIAlertAction(title: secondButtonText, style: .default) { _ in
                alert.secondCompletion?()
            }
            secondAction.accessibilityIdentifier = "Yes"
            alertModel.addAction(secondAction)
        }
        
        alertModel.view.accessibilityIdentifier = "Alert"
        var topController = UIApplication.shared.windows.first?.rootViewController
        while (topController?.presentedViewController != nil &&
               topController != topController!.presentedViewController) {
            topController = topController!.presentedViewController
        }
        topController?.present(alertModel, animated: true, completion: nil)
    }
    
    func setup(delegate: UIViewController) {
        self.delegate = delegate
    }

}
