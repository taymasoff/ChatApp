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
        
        gearBarButton = makeGearBarButton()
        conversationsTableView = makeConversationsTableView()
        newConversationButton = makeNewConversationButton()
        searchController = makeSearchController()
        setupNewConversationView()
        
        navigationItem.title = viewModel?.title
        navigationItem.leftBarButtonItem = gearBarButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        conversationsTableView.register(ConversationCell.self,
                                        forCellReuseIdentifier: ConversationCell.reuseID)
        
        conversationsTableView.rowHeight = 80
        
        navigationItem.searchController = searchController
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        // Для корректного отображения SearchControllerа
        extendedLayoutIncludesOpaqueBars = true
        
        setupRefreshControl()
        viewModel?.fetchUserAvatarOrName()
        bindWithViewModel()
        subscribeToNotificationUpdates()
        viewModel?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObserver()
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
        viewModel?.didRequestRefresh { [unowned self] in
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

extension ConversationsViewController: ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.profileAvatarUpdateInfo.bind(listener: { [unowned self] update in
            updateProfileBarButton(with: update)
        })
        viewModel?.onDataUpdate = { [unowned self] in
            DispatchQueue.main.async {
                self.conversationsTableView.reloadData()
            }
        }
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
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        view.textLabel?.textColor = ThemeManager.currentTheme.settings.titleTextColor
        return view
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.didSwipeToDelete(at: indexPath)
        }
    }
}

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
