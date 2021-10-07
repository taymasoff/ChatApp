//
//  ConversationCell+Subviews.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import UIKit

extension ConversationCell {
    
    // MARK: - Create Subviews
    func makeCellContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
    
    func makeAllTextContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func makeNameDateContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func makeProfileImageView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.clipsToBounds = true
        return imageView
    }
    
    func makeOnlineIndicatorView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        view.backgroundColor = AppAssets.colors(.statusGreen)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 7
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let label = UILabel()
        label.font = AppAssets.font(.sfProText, type: .semibold, size: 15)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    func makeDateLabel() -> UILabel {
        let label = UILabel()
        label.font = AppAssets.font(.sfProText, type: .regular, size: 15)
        label.textColor = AppAssets.colors(.footerGray)
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }
    
    func makeLastMessageLabel() -> UILabel {
        let label = UILabel()
        label.font = AppAssets.font(.sfProText, type: .regular, size: 13)
        label.textColor = AppAssets.colors(.footerGray)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }
    
    // MARK: - Subviews Setup Methods
    func setupSubviews() {
        cellContainer = makeCellContainer()
        allTextContainer = makeAllTextContainer()
        nameDateContainer = makeNameDateContainer()
        
        profileImageView = makeProfileImageView()
        nameLabel = makeNameLabel()
        lastMessageLabel = makeLastMessageLabel()
        dateLabel = makeDateLabel()
        onlineIndicatorView = makeOnlineIndicatorView()
    }
    
    func setupSubviewsHierarchy() {
        contentView.addSubview(cellContainer)
        cellContainer.addSubview(profileImageView)
        cellContainer.addSubview(allTextContainer)
        nameDateContainer.addSubview(nameLabel)
        nameDateContainer.addSubview(dateLabel)
        allTextContainer.addSubview(nameDateContainer)
        allTextContainer.addSubview(lastMessageLabel)
        cellContainer.addSubview(onlineIndicatorView)
    }
    
    func setupSubviewsLayout() {
        nameLabel.setContentHuggingPriority(UILayoutPriority(200), for: .horizontal)
        
        profileImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(15)
            layoutSubviews()
            make.width.equalTo(profileImageView.snp.height)
        }
        
        let profileImageRadius = profileImageView.frame.width / 2
        profileImageView.layer.cornerRadius = profileImageRadius
        
        let xCoord = profileImageRadius * sin(135 * (Double.pi / 180))
        let yCoord = profileImageRadius * cos(135 * (Double.pi / 180))
        
        onlineIndicatorView.snp.makeConstraints { make in
            make.size.equalTo(14)
            make.centerX.equalTo(profileImageView.snp.centerX).offset(xCoord)
            make.centerY.equalTo(profileImageView.snp.centerY).offset(yCoord)
        }
        
        allTextContainer.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(12)
        }
        
        nameDateContainer.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(lastMessageLabel.snp.top)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(dateLabel.snp.left)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }
        
        cellContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
