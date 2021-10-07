//
//  DMViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

typealias DMViewModelProtocol = DMViewModelPresentable & DMTableViewCompatible

final class DMViewController: UIViewController {
    
    var viewModel: DMViewModelProtocol!
    
    var tableView: UITableView!
    var footerView: UIView!
    var newMessageTextField: UITextField!
    var addButton: UIButton!
    var sendButton: UIButton!
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = AppAssets.colors(.appGray)
        
        setupSubviews()
        setupSubviewsHierarchy()
        setupSubviewsLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        clearBackButtonText()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    private func configureTableView() {
        tableView.register(MessageCell.self,
                           forCellReuseIdentifier: MessageCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = calculateEstimatedRowHeight()
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
    
    private func calculateEstimatedRowHeight() -> CGFloat {
        // 17 - примерная высота 1 строки TextView при текущем шрифте
        return CGFloat(17 + MessageCell.timePadding*2 + MessageCell.textPadding*2 + MessageCell.bubbleMargin*2)
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

// MARK: - UITableView Delegate & Data Source
extension DMViewController: UITableViewDataSource, UITableViewDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier,
                                                 for: indexPath) as? MessageCell
        
        guard let cell = cell else {
            Log.error("Не удалось найти MessageCell по идентификатору \(MessageCell.identifier). Возможно введен не верный ID.")
            return UITableViewCell()
        }
        
        let messageCellViewModel = viewModel.messageCellViewModel(forIndexPath: indexPath)
    
        cell.configure(with: messageCellViewModel)
        
        return cell
    }
}

// MARK: - UITextField Delegate
extension DMViewController: UITextFieldDelegate {
    
}

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
            
            footerView.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
            
            footerView.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
