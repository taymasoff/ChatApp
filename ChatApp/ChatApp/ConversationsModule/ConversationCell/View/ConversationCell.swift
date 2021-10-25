//
//  ConversationCell.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import SnapKit
import Rswift

/// Ячейка диалога
final class ConversationCell: UITableViewCell, ReuseIdentifiable, Configurable {
    
    // MARK: - Properties
    fileprivate var profileImageView: UIImageView!
    fileprivate var nameLabel: UILabel!
    fileprivate var lastMessageLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var onlineIndicatorView: UIView!
    
    fileprivate var allTextContainer: UIView!
    fileprivate var nameDateContainer: UIView!
    fileprivate var cellContainer: UIView!
    
    var viewModel: ConversationCellViewModel?
    
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
}

extension ConversationCell: ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.conversationImage.bind { [unowned self] image in
            profileImageView.subviews.forEach { $0.removeFromSuperview() }
            if let profileImage = image {
                profileImageView.image = profileImage
            } else {
                profileImageView.addAbbreviatedPlaceholder(
                    text: viewModel?.name.value
                )
            }
        }
        viewModel?.name.bind { [unowned self] name in
            nameLabel.text = name
        }
        viewModel?.lastActivity.bind { [unowned self] date in
            dateLabel.text = date
        }
        viewModel?.lastMessage.bind { [unowned self] message in
            if let message = message {
                lastMessageLabel.text = message
                lastMessageLabel.textColor = ThemeManager.currentTheme.settings.subtitleTextColor
            } else {
                lastMessageLabel.text = "No messages yet"
                lastMessageLabel.textColor = ThemeManager.currentTheme.settings.tintColor
            }
        }
        viewModel?.isActive.bind { [unowned self] isActive in
            onlineIndicatorView.isHidden = !(isActive ?? false)
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
                self?.contentView.backgroundColor = ThemeManager.currentTheme.settings.tintColor
                self?.cellContainer.backgroundColor = ThemeManager.currentTheme.settings.backGroundColor
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
                self?.cellContainer.backgroundColor = .clear
                self?.cellContainer.layer.cornerRadius = 0
                self?.contentView.backgroundColor = .clear
            }, completion: completion)
        }
    }
}

// MARK: - Setup Subviews
private extension ConversationCell {
    
    // MARK: - Create Subviews
    func makeCellContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
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
        view.backgroundColor = R.color.statusGreen()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 7
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = ThemeManager.currentTheme.settings.titleTextColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    func makeDateLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ThemeManager.currentTheme.settings.subtitleTextColor
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }
    
    func makeLastMessageLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = ThemeManager.currentTheme.settings.subtitleTextColor
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
        
        // MARK: Layout Profile Image View
        profileImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(15)
            layoutSubviews()
            make.width.equalTo(profileImageView.snp.height)
        }
        
        let profileImageRadius = profileImageView.frame.width / 2
        profileImageView.layer.cornerRadius = profileImageRadius
        
        let xCoord = profileImageRadius * sin(135 * (Double.pi / 180))
        let yCoord = profileImageRadius * cos(135 * (Double.pi / 180))
        
        // MARK: Layout Online Indicator View
        onlineIndicatorView.snp.makeConstraints { make in
            make.size.equalTo(14)
            make.centerX.equalTo(profileImageView.snp.centerX).offset(xCoord)
            make.centerY.equalTo(profileImageView.snp.centerY).offset(yCoord)
        }
        
        // MARK: Layout All Text Container
        allTextContainer.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(12)
        }
        
        // MARK: Layout Name Date Container
        nameDateContainer.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(lastMessageLabel.snp.top)
        }
        
        // MARK: Layout Last Message Label
        lastMessageLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        // MARK: Layout Name Label
        nameLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(dateLabel.snp.left)
        }
        
        // MARK: Layout Date Label
        dateLabel.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }
        
        // MARK: Layout Cell Container
        cellContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
