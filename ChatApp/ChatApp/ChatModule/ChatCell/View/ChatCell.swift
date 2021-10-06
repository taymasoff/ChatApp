//
//  ChatCell.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

class ChatCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "ConversationsChatCell"
    
    private var viewModel: ChatCellViewModelProtocol!
    
    var profileImageView: UIImageView!
    var nameLabel: UILabel!
    var lastMessageLabel: UILabel!
    var dateLabel: UILabel!
    var onlineIndicatorView: UIView!
    
    var allTextContainer: UIView!
    var nameDateContainer: UIView!
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        viewModel = ChatCellViewModel()
        
        setupSubviews()
        setupSubviewsHierarchy()
        setupSubviewsLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Internal Methods
    func configure(_ conversation: ConversationViewDataType) {
        viewModel.configure(conversation)
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.profileImage.bind { [unowned self] image in
            profileImageView.subviews.forEach { $0.removeFromSuperview() }
            if let profileImage = image {
                profileImageView.image = profileImage
            } else {
                profileImageView.addProfilePlaceholder(fullName: viewModel.name.value)
            }
        }
        viewModel.name.bind { [unowned self] name in
            nameLabel.text = name
        }
        viewModel.date.bind { [unowned self] date in
            dateLabel.text = date
        }
        viewModel.lastMessage.bind { [unowned self] message in
            if let message = message {
                lastMessageLabel.text = message
                lastMessageLabel.textColor = AppAssets.colors(.footerGray)
            } else {
                lastMessageLabel.text = "No messages yet"
                lastMessageLabel.textColor = .systemBlue
            }
        }
        viewModel.hasUnreadMessages.bind { [unowned self] hasUnread in
            changeLastMessageLabelState(hasUnread ?? false)
        }
        viewModel.isOnline.bind { [unowned self] isOnline in
            onlineIndicatorView.isHidden = !(isOnline ?? false)
        }
    }
    
    private func changeLastMessageLabelState(_ hasUnread: Bool) {
        switch hasUnread {
        case true:
            lastMessageLabel.font = AppAssets.font(.sfProText, type: .bold, size: 13)
        case false:
            lastMessageLabel.font = AppAssets.font(.sfProText, type: .regular, size: 13)
        }
    }
}
