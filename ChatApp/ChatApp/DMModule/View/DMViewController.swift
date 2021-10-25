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
    fileprivate var tableView: UITableView!
    fileprivate var footerView: UIView!
    fileprivate var newMessageTextField: UITextField!
    fileprivate var addButton: UIButton!
    fileprivate var sendButton: UIButton!
    
    var viewModel: DMViewModel?
    
    // MARK: - Initializers
    convenience init(with viewModel: DMViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        
        setupSubviews()
        setupSubviewsHierarchy()
        setupSubviewsLayout()
        
        clearBackButtonText()
        configureTableView()
        bindWithViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollToBottom(animated: false)
    }
    
    // MARK: - Private Methods
    private func configureTableView() {
        tableView.register(MessageCell.self,
                           forCellReuseIdentifier: MessageCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = calculateEstimatedRowHeight()
    }
    
    private func clearBackButtonText() {
        let backButton = UIBarButtonItem()
        backButton.tintColor = ThemeManager.currentTheme.settings.tintColor
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func calculateEstimatedRowHeight() -> CGFloat {
        // 17 - примерная высота 1 строки TextView при текущем шрифте
        return CGFloat(
            17 + MessageCell.timePadding * 2 +
            MessageCell.textPadding * 2 +
            MessageCell.bubbleMargin * 2
        )
    }
    
    @objc
    func sendMessagePressed() {
        Log.info("Send Button Pressed")
    }
    
    @objc
    func addButtonPressed() {
        Log.info("Add Button Pressed")
    }
}

// MARK: - ViewModelBindable
extension DMViewController: ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.chatImage.bind(listener: { [unowned self] image in
            setNavTitleWithImage(title: self.viewModel?.chatName.value,
                                 image: image)
        })
    }
}

// MARK: - UITableView Delegate & Data Source
extension DMViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.titleForHeaderInSection(section) ?? ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseID,
                                                 for: indexPath) as? MessageCell
        
        guard let cell = cell else {
            Log.error("Не удалось найти MessageCell по идентификатору \(MessageCell.reuseID). Возможно введен не верный ID.")
            return UITableViewCell()
        }
        
        guard let messageCellViewModel = viewModel?.messageCellViewModel(forIndexPath: indexPath) else {
            Log.error("Не удалось создать MessageCellViewModel по indexPath: \(indexPath).")
            return UITableViewCell()
        }
        
        cell.configure(with: messageCellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        view.textLabel?.textColor = ThemeManager.currentTheme.settings.titleTextColor
        return view
    }
}

// MARK: - UITextField Delegate
extension DMViewController: UITextFieldDelegate { }

// MARK: - KeyboardObservers
/*
 Когда появляется клавиатура - смещаем вьюшку наверх с той же скоростью, с которой появляется клавиатура. Когда клавиатура убирается, делаем то же самое, только наоборот.
 */

private extension DMViewController {
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
            
            newMessageTextField.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10).offset(-keyboardSize.height)
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            newMessageTextField.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Setup Subviews
private extension DMViewController {
    
    // MARK: - Create Subviews
    func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }
    
    func makeFooterContainer() -> UIView {
        let footerView = UIView()
        footerView.backgroundColor = ThemeManager.currentTheme.settings.backGroundColor
        // Скругляем верхние углы
        footerView.layer.cornerRadius = 10
        footerView.layer.maskedCorners = [.layerMaxXMinYCorner,
                                          .layerMinXMinYCorner]
        return footerView
    }
    
    func makeAddButton() -> UIButton {
        let button = UIButton(type: .system)
        let tintedImage = R.image.add()?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = ThemeManager.currentTheme.settings.tintColor
        button.addTarget(self,
                         action: #selector(addButtonPressed),
                         for: .touchUpInside)
        return button
    }
    
    func makeNewMessageTextField() -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Type your message..."
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .default
        textField.keyboardType = .default
        textField.returnKeyType = .send
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.delegate = self
        
        return textField
    }
    
    func makeSendButton() -> UIButton {
        let button = UIButton(type: .system)
        let tintedImage = R.image.send()?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = ThemeManager.currentTheme.settings.tintColor
        button.addTarget(self,
                         action: #selector(sendMessagePressed),
                         for: .touchUpInside)
        return button
    }
    
    // MARK: - Subviews Setup Methods
    func setupSubviews() {
        footerView = makeFooterContainer()
        tableView = makeTableView()
        addButton = makeAddButton()
        newMessageTextField = makeNewMessageTextField()
        sendButton = makeSendButton()
    }
    
    func setupSubviewsHierarchy() {
        view.addSubview(tableView)
        view.addSubview(footerView)
        footerView.addSubview(newMessageTextField)
        footerView.addSubview(addButton)
        footerView.addSubview(sendButton)
    }
    
    func setupSubviewsLayout() {
        // MARK: Layout Table View
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }

        // MARK: Layout Footer View
        footerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(newMessageTextField.snp.top).inset(-20)
            
        }
        
        // MARK: Layout New Message TextField
        newMessageTextField.snp.makeConstraints { make in
            make.left.equalTo(addButton.snp.right).offset(13)
            make.right.equalTo(sendButton.snp.left).offset(-13)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.height.equalTo(newMessageTextField.intrinsicContentSize.height + 6)
        }
        
        // MARK: Layout New Message' Add Button
        addButton.snp.makeConstraints { make in
            make.bottom.top.equalTo(newMessageTextField).inset(10)
            make.width.equalTo(addButton.snp.height)
            make.left.equalToSuperview().inset(13)
        }

        // MARK: Layout New Message' Send Button
        sendButton.snp.makeConstraints { make in
            make.bottom.top.equalTo(newMessageTextField).inset(10)
            make.width.equalTo(addButton.snp.height)
            make.right.equalToSuperview().inset(20)
        }
    }
}
