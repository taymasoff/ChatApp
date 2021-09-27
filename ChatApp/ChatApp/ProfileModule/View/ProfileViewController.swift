//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    
    var viewModel: ProfileViewModelProtocol!
    
    lazy var closeBarButton: UIBarButtonItem = makeCloseBarButton()
    
    override func loadView() {
        super.loadView()
        
        navigationItem.rightBarButtonItem = closeBarButton
        
        setLeftAlignTitleView(
            font: AppAssets.font(.sfProDisplay, type: .semibold, size: 26),
            text: "My Profile",
            textColor: .black)
        
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.info("ProfileVC Loaded")
    }
    
    @objc
    func closeBarButtonPressed() {
        Log.info("Close Bar Button Pressed")
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
