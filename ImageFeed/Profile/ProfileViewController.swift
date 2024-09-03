//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Olga Trofimova on 03.09.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private var exitImage: UIButton!
    @IBOutlet private var mainNameLabel: UILabel!
    @IBOutlet private var userpick: UIImageView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var logoLabel: UILabel!
    
    @IBOutlet private var favoritesLabel: UILabel!
    @IBOutlet private var notificationLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        logoLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        favoritesLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        notificationLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        notificationLabel.layer.cornerRadius = 69
    }
    
    @IBAction func exitProfile(_ sender: Any) {
    }
    
    
}
