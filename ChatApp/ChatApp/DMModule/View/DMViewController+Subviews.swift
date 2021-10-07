//
//  DMViewController+Subviews.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 06.10.2021.
//

import UIKit
import SnapKit

extension DMViewController {
    
    // MARK: - Create Subviews
    func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        
        return tableView
    }
    
    func makeFooterContainer() -> UIView {
        let footerView = UIView()
        footerView.backgroundColor = AppAssets.colors(.appGray)
    
        return footerView
    }
    
    func makeAddButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(AppAssets.image(.add), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self,
                         action: #selector(addButtonPressed),
                         for: .touchUpInside)
        return button
    }
    
    func makeNewMessageTextField() -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Type your message..."
        textField.font = AppAssets.font(.sfProText, type: .regular, size: 17)
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
        let button = UIButton(type: .custom)
        button.setImage(AppAssets.image(.send), for: .normal)
        button.tintColor = .systemBlue
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
            make.height.equalTo(80)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // MARK: Layout New Message TextField
        newMessageTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.left.equalTo(addButton.snp.right).offset(13)
            make.right.equalTo(sendButton.snp.left).offset(-13)
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
