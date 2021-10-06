//
//  ConversationCell.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "ConversationCell"
    
    lazy var viewModel: ConversationCellViewModelProtocol = {
        return ConversationCellViewModel()
    }()
    
    var profileImageView: UIImageView!
    var nameLabel: UILabel!
    var lastMessageLabel: UILabel!
    var dateLabel: UILabel!
    var onlineIndicatorView: UIView!
    
    var allTextContainer: UIView!
    var nameDateContainer: UIView!
    var cellContainer: UIView!
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        setupSubviewsHierarchy()
        setupSubviewsLayout()
        
        self.selectionStyle = .none
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

// MARK: - OnSelect Animations
extension ConversationCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(isHighlighted: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(isHighlighted: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(isHighlighted: false)
    }
    
    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)? = nil) {
        let animationOptions: UIView.AnimationOptions = [.allowUserInteraction]
        if isHighlighted {
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions,
                           animations: { [weak self] in
                self?.cellContainer.transform = .init(scaleX: 0.93, y: 0.9)
                self?.contentView.backgroundColor = AppAssets.colors(.appYellow)
                self?.cellContainer.layer.cornerRadius = 15
                
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions,
                           animations: { [weak self] in
                self?.cellContainer.transform = .identity
                self?.cellContainer.layer.cornerRadius = 0
                self?.contentView.backgroundColor = .white
            }, completion: completion)
        }
    }
}
