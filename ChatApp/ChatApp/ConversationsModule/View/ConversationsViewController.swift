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
    private let newConversationView: NewConversationView = NewConversationView()
    private lazy var inAppNotification = InAppNotificationBanner()
    
    var viewModel: ConversationsViewModel?
    private lazy var nameFormatter = PersonNameComponentsFormatter()
    
    // MARK: - Initializers
    convenience init(with viewModel: ConversationsViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - UIViewController Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupAppeareance()
        configureTableView()
        
        bindWithViewModel()
        subscribeToConversationProviderUpdates()
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
        newConversationButton = makeNewConversationButton()
        searchController = makeSearchController()
        setupNewConversationView()
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
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = viewModel?.conversationsProvider
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
    
    @objc
    private func newConversationButtonPressed() {
        revealNewConversationView()
    }
    
    @objc
    private func addConversationButtonPressed() {
        viewModel?.newConversationButtonPressed(
            with: newConversationView.nameTextField.text
        )
        newConversationView.nameTextField.text = ""
        collapseNewConversationView()
    }
    
    @objc
    private func cancelAddingConversationButtonPressed() {
        collapseNewConversationView()
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
    private func subscribeToConversationProviderUpdates() {
        viewModel?.conversationsProvider.changes.bind { [weak self] changes in
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

// MARK: - UITableView Delegate
extension ConversationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        view.textLabel?.textColor = ThemeManager.currentTheme.settings.titleTextColor
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [unowned self] _, _, complete in
            self.viewModel?.didSwipeToDelete(at: indexPath) { _ in
                complete(true)
            }
        }
        
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

// MARK: - UITextFieldDelegate
extension ConversationsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if newConversationView.isSendable {
            addConversationButtonPressed()
        }
        return true
    }
    
    @objc
    func nameTextFieldDidChange(_ textField: UITextField) {
        if let isSendable = viewModel?.isTextSendable(text: textField.text) {
            newConversationView.isSendable = isSendable
        }
    }
}

// MARK: - Update NewConversationViewState
private extension ConversationsViewController {
    
    func revealNewConversationView(animated: Bool = true) {
        newConversationView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(newConversationButton)
            make.height.equalToSuperview().dividedBy(6)
        }
        newConversationView.viewState = .revealed
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseOut]) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    func collapseNewConversationView(animated: Bool = true) {
        newConversationView.snp.remakeConstraints { make in
            make.edges.equalTo(newConversationButton)
        }
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations: { [weak self] in
                self?.view.layoutIfNeeded()
                
            }, completion: { [weak self] _ in
                self?.newConversationView.viewState = .collapsed
            })
        } else {
            newConversationView.viewState = .collapsed
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
    
    func makeNewConversationButton() -> UIButton {
        let button = UIButton(type: .system)
        let buttonSize = view.frame.width / 6
        let tintedImage = R.image.add()?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: CGFloat(buttonSize / 3),
                                              left: CGFloat(buttonSize / 3),
                                              bottom: CGFloat(buttonSize / 3),
                                              right: CGFloat(buttonSize / 3))
        button.layer.cornerRadius = CGFloat(buttonSize / 2)
        button.backgroundColor = ThemeManager.currentTheme.settings.secondaryColor
        button.tintColor = ThemeManager.currentTheme.settings.tintColor
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.size.equalTo(buttonSize)
            make.right.equalToSuperview().inset(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        
        button.addTarget(
            self,
            action: #selector(newConversationButtonPressed),
            for: .touchUpInside
        )
        
        return button
    }
    
    func setupNewConversationView() {
        view.addSubview(newConversationView)
        
        newConversationView.nameTextField.delegate = self
    
        newConversationView.okButton.addTarget(
            self,
            action: #selector(addConversationButtonPressed),
            for: .touchUpInside
        )
        newConversationView.cancelButton.addTarget(
            self,
            action: #selector(cancelAddingConversationButtonPressed),
            for: .touchUpInside
        )
        
        newConversationView.snp.makeConstraints { make in
            make.edges.equalTo(newConversationButton)
        }
        
        newConversationView.viewState = .collapsed
        
        newConversationView.nameTextField.addTarget(
            self,
            action: #selector(nameTextFieldDidChange),
            for: .editingChanged
        )
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
        self.definesPresentationContext = true
        return searchController
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

// MARK: - KeyboardObservers
private extension ConversationsViewController {
    func addKeyboardObserver() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(keyboardWillShow),
                         name: UIResponder.keyboardWillShowNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(keyboardWillHide),
                         name: UIResponder.keyboardWillHideNotification,
                         object: nil)
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            newConversationButton.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                    .inset(20)
                    .offset(-keyboardSize.height)
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            newConversationButton.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                    .inset(20)
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
