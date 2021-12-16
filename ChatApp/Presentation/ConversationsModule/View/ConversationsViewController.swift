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
    static let rowHeight: CGFloat = 80
    
    // MARK: - Properties
    private var profileBarButton: UIBarButtonItem? {
        didSet {
            updateNavBarItem(with: profileBarButton, animated: true)
        }
    }
    private var gearBarButton: UIBarButtonItem!
    private var conversationsTableView: UITableView!
    private var searchController: UISearchController!
    private var newConversationButton: UIButton!
    private let newConversationController: NewConversationController
    private lazy var inAppNotification = InAppNotificationBanner()
    private lazy var nameFormatter = PersonNameComponentsFormatter()
    
    var viewModel: ConversationsViewModel?
    
    // MARK: - Initializers
    init(newConversationController: NewConversationController) {
        self.newConversationController = newConversationController
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(with viewModel: ConversationsViewModel,
                     newConversationController: NewConversationController) {
        self.init(newConversationController: newConversationController)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupAppeareance()
        configureTableView()
        
        bindWithViewModel()
        subscribeToTableViewUpdates()
        subscribeToNotificationUpdates()
        viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    // MARK: - Config Methods
    private func setupSubviews() {
        gearBarButton = makeGearBarButton()
        conversationsTableView = makeConversationsTableView()
        searchController = makeSearchController()
        setupNewConversationController()
        setupRefreshControl()
    }
    
    private func setupAppeareance() {
        navigationItem.title = viewModel?.title
        navigationItem.leftBarButtonItem = gearBarButton
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        // Для корректного отображения SearchControllerа
        extendedLayoutIncludesOpaqueBars = true
    }
    
    private func configureTableView() {
        conversationsTableView.register(ConversationCell.self,
                                        forCellReuseIdentifier: ConversationCell.reuseID)
        conversationsTableView.rowHeight = Self.rowHeight
        conversationsTableView.delegate = viewModel
        conversationsTableView.dataSource = viewModel?.conversationsTableViewDataSource
    }
    
    // MARK: - Action Methods
    @objc
    private func profileBarButtonPressed() {
        viewModel?.profileBarButtonPressed()
    }
    
    @objc
    private func gearBarButtonPressed() {
        viewModel?.gearBarButtonPressed()
    }
    
    @objc
    private func didPullToRefresh() {
        viewModel?.didRequestRefresh { [unowned self] _ in
            self.conversationsTableView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - ViewModelBindable
extension ConversationsViewController: ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.profileAvatarUpdateInfo.bind(listener: { [unowned self] update in
            updateProfileBarButton(with: update)
        })
    }
}

// MARK: - TableViewProvider Updates
extension ConversationsViewController {
    private func subscribeToTableViewUpdates() {
        viewModel?.tableViewChanges.bind { [weak self] changes in
            guard !changes.isEmpty else { return }
            
            self?.updateTableViewIfVisible(withChanges: changes)
        }
    }
    
    private func updateTableViewIfVisible(withChanges changes: [DataSourceChange]) {
        guard isViewLoaded && view.window != nil else { return }
        conversationsTableView.performBatchUpdates {
            for change in changes {
                switch change {
                case let .section(sectionUpdate):
                    switch sectionUpdate {
                    case let .inserted(ind):
                        conversationsTableView.insertSections([ind],
                                                              with: .none)
                    case let .deleted(ind):
                        conversationsTableView.deleteSections([ind],
                                                              with: .none)
                    }
                case let .object(objectUpdate):
                    switch objectUpdate {
                    case let .inserted(at: indexPath):
                        conversationsTableView.insertRows(at: [indexPath],
                                                          with: .automatic)
                    case let .deleted(from: indexPath):
                        conversationsTableView.deleteRows(at: [indexPath],
                                                          with: .automatic)
                    case let .updated(at: indexPath):
                        conversationsTableView.reloadRows(at: [indexPath],
                                                          with: .none)
                    case let .moved(from: fromIndexPath, to: toIndexPath):
                        conversationsTableView.deleteRows(at: [fromIndexPath],
                                                          with: .none)
                        conversationsTableView.insertRows(at: [toIndexPath],
                                                          with: .none)
                    }
                }
            }
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
        let imageViewSize = 35
        let imageView = UIImageView()
        imageView.layer.cornerRadius = CGFloat(imageViewSize / 2)
        imageView.layer.masksToBounds = true
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "profileBarButton"
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
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear
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
        searchController.searchBar.tintColor = ThemeManager.currentTheme.settings.tintColor
        searchController.searchBar.barTintColor = ThemeManager.currentTheme.settings.mainColor
        searchController.searchBar.barStyle = ThemeManager.currentTheme.settings.barStyle
        searchController.searchBar.backgroundColor = ThemeManager.currentTheme.settings.backGroundColor
        
        searchController.searchBar.forceTextFieldAppearance(
            textColor: ThemeManager.currentTheme.settings.titleTextColor,
            placeholderColor: ThemeManager.currentTheme.settings.subtitleTextColor
        )
        
        self.definesPresentationContext = true
        return searchController
    }
    
    func setupNewConversationController() {
        newConversationController.addToView(self.view, constraints: { make in
            make.size.equalTo(view.frame.width / 6)
            make.right.equalToSuperview().inset(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        })
        
        newConversationController.onAddConversationPressed = { [weak self] text in
            self?.viewModel?.newConversationButtonPressed(with: text)
        }
    }
    
    func setupRefreshControl() {
        conversationsTableView.refreshControl = UIRefreshControl()
        conversationsTableView.refreshControl?
            .addTarget(self,
                       action: #selector(didPullToRefresh),
                       for: .valueChanged)
    }
}

// MARK: - InAppNotification Updates
private extension ConversationsViewController {
    func subscribeToNotificationUpdates() {
        viewModel?.notificationCallback.bind { [unowned self] state in
            switch state {
            case .showSucces(let vm):
                self.showSuccessNotification(vm)
            case .showError(let vm):
                self.showErrorNotification(vm)
            case .none:
                break
            }
        }
    }
    
    // MARK: ViewModel Sent Error -> Show Error Notification
    func showErrorNotification(_ vm: InAppNotificationViewModel) {
        inAppNotification.configure(with: vm)
        inAppNotification.show()
        inAppNotification.onButtonOnePress = { [weak self] in
            self?.inAppNotification.dismiss()
        }
    }
    
    // MARK: ViewModel Sent Success -> Show Success Notification
    func showSuccessNotification(_ vm: InAppNotificationViewModel) {
        inAppNotification.configure(with: vm)
        inAppNotification.show()
        inAppNotification.onButtonOnePress = { [weak self] in
            self?.inAppNotification.dismiss()
        }
    }
}

// MARK: - KeyboardObserving
extension ConversationsViewController: KeyboardObserving {
    
    func keyboardWillShow(keyboardSize: CGRect, duration: Double) {
        newConversationController.revealButton.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(20)
                .offset(-keyboardSize.height)
        }
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(duration: Double) {
        newConversationController.revealButton.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(20)
        }
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
