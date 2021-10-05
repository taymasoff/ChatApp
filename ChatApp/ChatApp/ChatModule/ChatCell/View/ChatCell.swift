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
    
    var profileImageView: UIImageView!
    var nameLabel: UILabel!
    var lastMessageLabel: UILabel!
    var dateLabel: UILabel!
    var onlineIndicatorView: UIView!
    
    var cellHorizontalStackView: UIStackView!
    var textVerticalStackView: UIStackView!
    var nameDateHorizontalStackView: UIStackView!
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        setupSubviewsHierarchy()
        setupSubviewsLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subview Setup Methods
    private func setupSubviews() {
        cellHorizontalStackView = makeCellHorizontalStackView()
        textVerticalStackView = makeTextVerticalStackView()
        nameDateHorizontalStackView = makeNameDateHorizontalStackView()
        profileImageView = makeProfileImageView()
        nameLabel = makeNameLabel()
        lastMessageLabel = makeLastMessageLabel()
        dateLabel = makeDateLabel()
        onlineIndicatorView = makeOnlineIndicatorView()
    }
    
    private func setupSubviewsHierarchy() {
        contentView.addSubview(cellHorizontalStackView)
        cellHorizontalStackView.addSubview(profileImageView)
        cellHorizontalStackView.addSubview(textVerticalStackView)
        textVerticalStackView.addSubview(nameDateHorizontalStackView)
        nameDateHorizontalStackView.addSubview(nameLabel)
        nameDateHorizontalStackView.addSubview(dateLabel)
        textVerticalStackView.addSubview(nameDateHorizontalStackView)
        textVerticalStackView.addSubview(lastMessageLabel)
    }
    
    private func setupSubviewsLayout() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(contentView.snp.width).dividedBy(6)
        }
    }
    
    // MARK: - Internal Methods
    func configure(_ conversation: ConversationViewDataType) {
        nameLabel.text = conversation.userName
        lastMessageLabel.text = conversation.lastMessage
        dateLabel.text = conversation.messageDate
        
        if let profileImage = conversation.profileImage {
            profileImageView.image = profileImage
        } else {
            profileImageView.addProfilePlaceholder(fullName: conversation.userName)
        }
    }
}
