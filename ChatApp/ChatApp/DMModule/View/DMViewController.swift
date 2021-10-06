//
//  DMViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

final class DMViewController: UIViewController {
    
    var viewModel: DMViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        clearBackButtonText()
    }
    
    private func clearBackButtonText() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func bindViewModel() {
        viewModel.chatBuddyImage.bind { [unowned self] image in
            setNavTitleWithImage(title: viewModel.chatBuddyName.value,
                                 image: image)
        }
    }
}
