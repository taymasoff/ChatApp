//
//  ConversationsViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 22.09.2021.
//

import UIKit
import SnapKit
import Rswift

/// Контроллер экрана диалогов
final class ConversationsViewController: UIViewController, ViewModelBased {
    
    // MARK: - Properties
    fileprivate var profileBarButton: UIBarButtonItem!
    fileprivate var gearBarButton: UIBarButtonItem!
    fileprivate var conversationsTableView: UITableView!
    fileprivate var searchController: UISearchController!
    
    var viewModel: ConversationsViewModel?
    fileprivate lazy var nameFormatter = PersonNameComponentsFormatter()
    
    // MARK: - Initializers
    convenience init(with viewModel: ConversationsViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - UIViewController Lifecycle Methods
    override func loadView() {
        super.loadView()
        
        gearBarButton = makeGearBarButton()
        conversationsTableView = makeConversationsTableView()
        searchController = makeSearchController()
        
        updateProfileBarButton(with: "Marina Dudarenko")
        
        navigationItem.title = viewModel?.title
        navigationItem.leftBarButtonItem = gearBarButton
        navigationItem.rightBarButtonItem = profileBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversationsTableView.register(ConversationCell.self,
                                        forCellReuseIdentifier: ConversationCell.reuseID)
        conversationsTableView.rowHeight = 80
        
        navigationItem.searchController = searchController
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        // Для корректного отображения SearchController'а
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - Private Methods
    @objc
    private func profileBarButtonPressed() {
        viewModel?.profileBarButtonPressed()
    }
    
    @objc
    private func gearBarButtonPressed() {
        viewModel?.gearBarButtonPressed()
    }
}
// MARK: - UITableView Delegate & Data Source
extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: ConversationCell.reuseID,
                                 for: indexPath) as? ConversationCell
        
        guard let cell = cell else {
            Log.error("Не удалось найти ConversationCell по идентификатору \(ConversationCell.reuseID). Возможно введен не верный ID.")
            return UITableViewCell()
        }
        
        guard let conversationCellViewModel = viewModel?.conversationCellViewModel(forIndexPath: indexPath) else {
            Log.error("Не удалось создать ConversationCellViewModel по indexPath: \(indexPath).")
            return UITableViewCell()
        }
    
        cell.configure(with: conversationCellViewModel)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Scroll Animation
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
            cell.transform = CGAffineTransform.identity
        }
    }
}

// MARK: - Update Bar Button Items Methods
// Обновляет ProfileBarButtonItem картинкой, или плейсхолдером с инициалами
private extension ConversationsViewController {
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
        imageView.addProfilePlaceholder(fullName: fullName,
                                        formattedBy: nameFormatter)
        imageView.addAction(target: self,
                            action: #selector(profileBarButtonPressed))
        profileBarButton = UIBarButtonItem(customView: imageView)
    }
}

// MARK: - Setup Subviews
private extension ConversationsViewController {
    func makeGearBarButton() -> UIBarButtonItem {
        let barButton = UIBarButtonItem(
            image: R.image.gear()?.resize(to: CGSize(width: 30, height: 30)),
            style: .plain,
            target: self,
            action: #selector(gearBarButtonPressed))
        barButton.tintColor = R.color.barItemGray()
        return barButton
    }
    
    func makeConversationsTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        return tableView
    }
    
    func makeSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self.viewModel
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        return searchController
    }
}
