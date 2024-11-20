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

protocol AlertPresenterDelegate: AnyObject {
    func showFailedLoginAlert()
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
            alertModel.addAction(secondAction)
        }
        
        alertModel.view.accessibilityIdentifier = "Alert"
        delegate?.present(alertModel, animated: true)
    }
    
    func setup(delegate: UIViewController) {
        self.delegate = delegate
    }

}
