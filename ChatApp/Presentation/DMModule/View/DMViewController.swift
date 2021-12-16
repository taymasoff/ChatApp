//
//  DMViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import SnapKit
import Rswift

/// Контроллер экрана чата с собеседником
final class DMViewController: UIViewController, ViewModelBased {

    // MARK: - Properties
    private let dmTableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    private let newMessageController: NewMessageController
    private lazy var titleView: TitleViewWithImage = TitleViewWithImage()
    
    var viewModel: DMViewModel?
    
    // MARK: - Initializers
    init(newMessageController: NewMessageController) {
        self.newMessageController = newMessageController
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(with viewModel: DMViewModel,
                     newMessageController: NewMessageController) {
        self.init(newMessageController: newMessageController)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviewsAndAppearence()
        
        bindWithViewModel()
        subscribeToTableViewUpdates()
        viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    // MARK: - Config Methods
    private func setupSubviewsAndAppearence() {
        view.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        navigationItem.largeTitleDisplayMode = .never
        setupDMTableView()
        setupNewMessageController()
        clearBackButtonText()
        configureTableView()
    }
    
    private func configureTableView() {
        dmTableView.register(MessageCell.self,
                           forCellReuseIdentifier: MessageCell.reuseID)
        dmTableView.rowHeight = UITableView.automaticDimension
        dmTableView.estimatedRowHeight = calculateEstimatedRowHeight()
        dmTableView.dataSource = viewModel?.dmTableViewDataSource
        dmTableView.delegate = viewModel
    }
    
    // MARK: - Actions
    private func sendMessagePressed(text: String) {
        viewModel?.sendMessagePressed(with: text)
    }
    
    private func addButtonPressed(sender: UIButton) {
        viewModel?.addButtonPressed(presentingVC: self) { [weak self] urlString in
            self?.handleAppendingURLToTextField(urlString: urlString)
        }
    }
    
    // MARK: - Private Methods
    private func clearBackButtonText() {
        let backButton = UIBarButtonItem()
        backButton.tintColor = ThemeManager.currentTheme.settings.tintColor
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func calculateEstimatedRowHeight() -> CGFloat {
        return CGFloat(MessageCell.estimatedContentHeight)
    }
    
    private func scrollTableViewToBottom() {
        view.layoutIfNeeded()
        dmTableView.scrollToBottom(animated: false)
    }
    
    private func handleAppendingURLToTextField(urlString: String) {
        // Добавляем urlString к текущему тексту
        let lastTextFieldValue: String = newMessageController.newMessageView.textField.text ?? ""
        newMessageController.newMessageView.textField.text = [lastTextFieldValue, urlString]
            .joined(separator: " ")
        // В ручную вызываем textFieldDidChange т.к. он не тригерится на изменения кодом
        newMessageController.textFieldDidChange(newMessageController.newMessageView.textField)
    }
}

// MARK: - ViewModelBindable
extension DMViewController: ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.chatImage.bind(listener: { [unowned self] image in
            if let image = image {
                titleView.updateUsing(image: image,
                                      title: viewModel?.chatName.value)
            } else {
                titleView.updateUsing(title: viewModel?.chatName.value,
                                      placeholderType: .forGroupChat)
            }
            self.navigationItem.titleView = titleView
        })
    }
}

// MARK: - TableViewProvider Updates
extension DMViewController {
    private func subscribeToTableViewUpdates() {
        viewModel?.dmTableViewChanges.bind { [weak self] changes in
            guard !changes.isEmpty else { return }
            
            self?.updateTableView(withChanges: changes)
        }
    }
    
    private func updateTableView(withChanges changes: [DataSourceChange]) {
        dmTableView.performBatchUpdates {
            for change in changes {
                switch change {
                case let .section(sectionUpdate):
                    switch sectionUpdate {
                    case let .inserted(ind):
                        dmTableView.insertSections([ind],
                                                 with: .none)
                    case let .deleted(ind):
                        dmTableView.deleteSections([ind],
                                                 with: .none)
                    }
                case let .object(objectUpdate):
                    switch objectUpdate {
                    case let .inserted(at: indexPath):
                        dmTableView.insertRows(at: [indexPath],
                                             with: .none)
                    case let .deleted(from: indexPath):
                        dmTableView.deleteRows(at: [indexPath],
                                             with: .fade)
                    case let .updated(at: indexPath):
                        dmTableView.reloadRows(at: [indexPath],
                                             with: .none)
                    case let .moved(from: fromIndexPath, to: toIndexPath):
                        dmTableView.deleteRows(at: [fromIndexPath],
                                             with: .none)
                        dmTableView.insertRows(at: [toIndexPath],
                                             with: .none)
                    }
                }
            }
        } completion: { [weak self] _ in
            self?.scrollTableViewToBottom()
        }
    }
}

// MARK: - KeyboardObserving
extension DMViewController: KeyboardObserving {
    
    func keyboardWillShow(keyboardSize: CGRect, duration: Double) {
        
        newMessageController.newMessageView.stackView.snp.updateConstraints { make in
            make.bottom.equalTo(
                newMessageController.newMessageView.safeAreaLayoutGuide.snp.bottom
            )
                .inset(20)
                .offset(-keyboardSize.height)
        }
        
        let tableOffsetY = dmTableView.contentSize.height - keyboardSize.height + 15
        dmTableView.contentOffset = CGPoint(x: 0, y: tableOffsetY)
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(duration: Double) {
        newMessageController.newMessageView.stackView.snp.updateConstraints { make in
            make.bottom.equalTo(
                newMessageController.newMessageView.safeAreaLayoutGuide.snp.bottom
            )
                .inset(20)
        }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - Setup Subviews
private extension DMViewController {
    
    // MARK: - Subviews Setup Methods
    func setupNewMessageController() {
        newMessageController.addToView(self.view, constraints: { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dmTableView.snp.bottom)
            make.bottom.equalToSuperview()
        })
        
        newMessageController.onSendMessagePressed = sendMessagePressed
        newMessageController.onAddButtonPressed = addButtonPressed(sender:)
    }
    
    func setupDMTableView() {
        view.addSubview(dmTableView)
        dmTableView.contentInsetAdjustmentBehavior = .never
        
        dmTableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
}
