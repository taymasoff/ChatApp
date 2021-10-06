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
    
    var profileBarButton: UIBarButtonItem!
    var gearBarButton: UIBarButtonItem!
    var chatTableView: UITableView!
    
    // MARK: - UIViewController Lifecycle Methods
    override func loadView() {
        super.loadView()
        
        gearBarButton = makeGearBarButton()
        chatTableView = makeChatTableView()
        
        updateProfileBarButton(with: "Marina Dudarenko")
        
        navigationItem.title = viewModel.title
        navigationItem.leftBarButtonItem = gearBarButton
        navigationItem.rightBarButtonItem = profileBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        chatTableView.rowHeight = 80
        
        setupSearchController()
        
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    
    // MARK: - Setup Gesture Recognizers
    private func setupGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: view,
            action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: - Objc Action Methods
    @objc
    func profileBarButtonPressed() {
        viewModel.profileBarButtonPressed()
    }
    
    @objc
    func gearBarButtonPressed() {
        
    }
}
// MARK: - UITableView Delegate & Data Source
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier,
                                                 for: indexPath) as? ChatCell
        guard let conversation = viewModel.conversation(forIndexPath: indexPath) else {
            Log.error("Cell at \(indexPath) didn't recieve proper data")
            return UITableViewCell()
        }
        cell?.configure(conversation)
        return cell ?? UITableViewCell()
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
    
    func updateProfileBarButton(with fullName: String?) {
        let imageView = UIImageView()
        imageView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        imageView.addProfilePlaceholder(fullName: fullName)
        imageView.addAction(target: self,
                            action: #selector(profileBarButtonPressed))
        profileBarButton = UIBarButtonItem(customView: imageView)
    }
}
