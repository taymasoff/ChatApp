//
//  MessageCell.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 28.10.2021.
//

import UIKit
import SnapKit
import Rswift

/// Ячейка сообщения
final class MessageCell: UITableViewCell, ReuseIdentifiable, ViewModelBased {
    typealias ImageCallback = (_ image: UIImage?, _ updatedText: String?) -> Void
    typealias UpdateCellImageHandler = (_ textViewText: String?,
                                        _ completion: @escaping ImageCallback) -> Void
    
    /// Направление расположения текстовых "баблов" в ячейке
    enum ChatBubbleDirection { case left, right }
    
    static var messageToScreenRatio: Float = 0.66
    private static let bubbleMargin: Int = 8
    private static let contentPadding: Int = 8
    static var estimatedContentHeight = 19 + 19 + 14 +
    MessageCell.contentPadding * 2 + MessageCell.bubbleMargin * 2
    
    private var bgBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        return view
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.textAlignment = .left
        textView.textContainer.lineFragmentPadding = .zero
        textView.textContainerInset = .zero
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return textView
    }()
    
    private var pictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = R.color.timeGray()
        label.textAlignment = .right
        return label
    }()
    
    private var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
    }()
    
    var viewModel: MessageCellViewModel?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviewsHierarchy()
        setConstantConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Config
    func updateCellImage(updateHandler: UpdateCellImageHandler) {
        pictureImageView.image = nil
        updateHandler(textView.text, didRecieveUpdatedTextAndImage)
    }
    
    private func didRecieveUpdatedTextAndImage(image: UIImage?, text: String?) {
        guard text != nil || image != nil else { return }
        
        if let newText = text, textView.text != newText {
            textView.text = newText
        }
        
        if let image = image {
            updateImageViewHeightConstraint(
                value: textView.frame.width / image.cropRatio
            )
            pictureImageView.image = image
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - Internal Methods
    private func updateSubviews(direction: ChatBubbleDirection) {
        switch direction {
        case .left:
            bgBubbleView.backgroundColor = R.color.dmGray()
        case .right:
            bgBubbleView.backgroundColor = R.color.dmGreen()
        }
        setupSubviewsLayout(direction: direction)
    }
}

// MARK: - ViewModelBindable
extension MessageCell: Configurable, ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.text.bind(listener: { [unowned self] text in
            textView.text = text
        })
        
        viewModel?.time.bind(listener: { [unowned self] time in
            timeLabel.text = time
        })
        
        viewModel?.isSender.bind(listener: { [unowned self] isSender in
            guard let isSender = isSender else {
                Log.error("MessageCellViewModel returns nil for sender")
                return
            }
            
            if isSender {
                updateSubviews(direction: .right)
            } else {
                updateSubviews(direction: .left)
            }
        })
        
        viewModel?.senderName.bind(listener: { [unowned self] name in
            if let isSender = viewModel?.isSender.value, isSender {
                nameLabel.text = ""
                nameLabel.isHidden = true
            } else {
                nameLabel.text = name?.capitalized
                nameLabel.isHidden = false
            }
        })
    }
}

// MARK: - Setup Subviews Methods
extension MessageCell {
    
    func setupSubviewsHierarchy() {
        contentView.addSubview(bgBubbleView)
        bgBubbleView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(textView)
        containerStackView.addArrangedSubview(pictureImageView)
        containerStackView.addArrangedSubview(timeLabel)
    }
    
    func setConstantConstraints() {
        pictureImageView.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(0)
        }
        bgBubbleView.snp.makeConstraints { make in
            make.edges.equalTo(containerStackView).inset(-Self.contentPadding)
        }
    }
    
    func updateImageViewHeightConstraint(value: CGFloat) {
        pictureImageView.snp.updateConstraints { make in
            make.height.lessThanOrEqualTo(value)
        }
    }
    
    func setupSubviewsLayout(direction: ChatBubbleDirection) {
        
        let insetFromScreen = contentView.bounds.size.width * CGFloat((1 - Self.messageToScreenRatio))
        
        switch direction {
        case .left:
            containerStackView.snp.remakeConstraints { make in
                make.left.top.bottom.equalTo(contentView).inset(Self.bubbleMargin + Self.contentPadding)
                make.right.lessThanOrEqualTo(contentView).inset(insetFromScreen)
            }
        case .right:
            containerStackView.snp.remakeConstraints { make in
                make.right.top.bottom.equalTo(contentView).inset(Self.bubbleMargin + Self.contentPadding)
                make.left.greaterThanOrEqualTo(contentView).inset(insetFromScreen)
            }
        }
    }
}
