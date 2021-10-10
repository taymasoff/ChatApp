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
    lazy var nameFormatter = PersonNameComponentsFormatter()
    
    var profileBarButton: UIBarButtonItem!
    var gearBarButton: UIBarButtonItem!
    
    // MARK: - UIViewController Lifecycle Methods
    override func loadView() {
        super.loadView()
        
        gearBarButton = makeGearBarButton()
        updateProfileBarButton(with: "Marina Dudarenko")
        
        navigationItem.title = "Chat"
        navigationItem.leftBarButtonItem = gearBarButton
        navigationItem.rightBarButtonItem = profileBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Objc Action Methods
    @objc
    func profileBarButtonPressed() {
        viewModel.router?.showProfileViewController(animated: true)
    }
    
    @objc
    func gearBarButtonPressed() {
    }
}

// MARK: - Update Bar Button Items Methods
// Обновляет ProfileBarButtonItem картинкой, или плейсхолдером с инициалами

private extension ChatViewController {
    func updateProfileBarButton(with image: UIImage?) {
        guard let image = image else {
            Log.error("No image was set. Updating Profile Bar Button with default image.")
            return updateProfileBarButton(with: "")
        }
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self,
                         action: #selector(profileBarButtonPressed),
                         for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        profileBarButton = UIBarButtonItem(customView: button)
    }
    
    func updateProfileBarButton(with fullName: String) {
        let imageView = UIImageView()
        imageView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        imageView.addProfilePlaceholder(fullName: fullName,
                                        formattedBy: nameFormatter)
        imageView.addAction(target: self,
                            action: #selector(profileBarButtonPressed))
        profileBarButton = UIBarButtonItem(customView: imageView)
    }
}
