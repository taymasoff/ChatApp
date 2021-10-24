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
    fileprivate var profileBarButton: UIBarButtonItem? {
        didSet {
            updateNavBarItem(with: profileBarButton, animated: true)
        }
    }
    fileprivate var gearBarButton: UIBarButtonItem!
    fileprivate var conversationsTableView: UITableView!
    
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
        
        navigationItem.title = viewModel?.title
        navigationItem.leftBarButtonItem = gearBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversationsTableView.register(ConversationCell.self,
                                        forCellReuseIdentifier: ConversationCell.reuseID)
        conversationsTableView.rowHeight = 80
        setupSearchController()
        viewModel?.fetchUserAvatarOrName()
        bindWithViewModel()
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

extension ConversationsViewController: ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.profileAvatarUpdateInfo.bind(listener: { [unowned self] update in
            updateProfileBarButton(with: update)
        })
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        view.textLabel?.textColor = ThemeManager.currentTheme.settings.titleTextColor
        return view
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
    func updateNavBarItem(with item: UIBarButtonItem? = nil,
                          animated: Bool = true) {
        let item = item != nil ? item : profileBarButton
        navigationItem.rightBarButtonItem = item
        if animated {
            navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.navigationItem.rightBarButtonItem?.customView?.alpha = 1.0
            }
        }
    }
    
    func updateProfileBarButton(with info: ProfileAvatarUpdateInfo?) {
        let imageViewSize = 40
        let imageView = UIImageView()
        imageView.layer.cornerRadius = CGFloat(imageViewSize / 2)
        imageView.layer.masksToBounds = true
        let button = UIButton(type: .custom)
        
        button.addTarget(self,
                         action: #selector(profileBarButtonPressed),
                         for: .touchUpInside)
        button.setBackgroundColor(.clear.withAlphaComponent(0.5), for: .highlighted)
        
        switch info {
        case .avatar(let image):
            imageView.image = image
        case .name(let name):
            imageView.addProfilePlaceholder(fullName: name,
                                            formattedBy: nameFormatter)
        default:
            imageView.addProfilePlaceholder(fullName: "")
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(imageViewSize)
        }
        
        imageView.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        
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
        barButton.tintColor = ThemeManager.currentTheme.settings.tintColor
        return barButton
    }
    
    func makeConversationsTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        return tableView
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self.viewModel
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = ThemeManager.currentTheme.settings.tintColor
        searchController.searchBar.barTintColor = ThemeManager.currentTheme.settings.mainColor
        searchController.searchBar.barStyle = ThemeManager.currentTheme.settings.barStyle
        searchController.searchBar.backgroundColor = ThemeManager.currentTheme.settings.backGroundColor
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
}
