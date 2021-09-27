//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import UIKit
import SnapKit

class ChatViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: ChatViewModelProtocol!
    
    lazy var profileImageView: UIImageView = makeDefaultProfileImageView(initials: "MD")
    lazy var profileBarButton: UIBarButtonItem = makeProfileBarButton(imageView: profileImageView)
    lazy var gearBarButton: UIBarButtonItem = makeGearBarButton()
    
    // MARK: - UIViewController Lifecycle Methods
    
    override func loadView() {
        super.loadView()
        
        navigationItem.title = "Chat"
        navigationItem.leftBarButtonItem = gearBarButton
        navigationItem.rightBarButtonItem = profileBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.info("ChatVC Loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Methods
    @objc
    func profileBarButtonPressed() {
        self.viewModel.router?.showProfileViewController(animated: true)
        Log.info("Profile Bar Button Pressed")
    }
    
    @objc
    func gearBarButtonPressed() {
        Log.info("Gear Bar Button Pressed")
    }
}

