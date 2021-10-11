//
//  MessageCell.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import UIKit
import SnapKit
import Rswift

/// Ячейка сообщения
final class MessageCell: UITableViewCell, ReuseIdentifiable, ViewModelBased {
    
    /// Направление расположения текстовых "баблов" в ячейке
    enum Direction {
        case left
        case right
    }
    
    // MARK: - Properties
    var bgBubbleView: UIView!
    var textView: UITextView!
    var timeLabel: UILabel!
    
    static var textPadding: Int = 6
    static var bubbleMargin: Int = 12
    static var timePadding: Int = 8
    static var messageToScreenRatio: Float = 0.66
    
    var viewModel: MessageCellViewModel?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviews()
        setupSubviewsHierarchy()
        setConstantConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    private func updateSubviews(direction: Direction) {
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
    }
}

// MARK: - Subviews Setup
extension MessageCell {
    
    // MARK: - Create Subviews
    func makeBgBubbleView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }
    
    func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.textAlignment = .left
        return textView
    }
    
    func makeTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = R.color.timeGray()
        label.textAlignment = .right
        return label
    }
    
    // MARK: - Setup Subviews Methods
    func setupSubviews() {
        bgBubbleView = makeBgBubbleView()
        textView = makeTextView()
        timeLabel = makeTimeLabel()
    }
    
    func setupSubviewsHierarchy() {
        contentView.addSubview(bgBubbleView)
        bgBubbleView.addSubview(textView)
        bgBubbleView.addSubview(timeLabel)
    }
    
    func setConstantConstraints() {
        // MARK: Layout BubbleView
        bgBubbleView.snp.makeConstraints { make in
            // Делаем минимальную ширину и высоту, чтобы все выглядело прилично, когда сообщение пустое или состоит из одного пробела
            make.width.greaterThanOrEqualTo(80)
            make.height.greaterThanOrEqualTo(40)
            make.left.top.right.equalTo(textView).inset(-MessageCell.textPadding)
            make.bottom.equalTo(timeLabel.snp.bottom).inset(-MessageCell.timePadding)
            // На случай, если лейбл со временем пустой
            make.bottom.greaterThanOrEqualTo(textView).inset(-MessageCell.textPadding)
        }
        
        // MARK: Layout TimeLabel
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom)
            make.right.equalTo(bgBubbleView).inset(MessageCell.timePadding)
        }
    }
    
    // Вряд ли когда либо будет динамически меняться отправитель сообщения, но на всякий случай пусть будет так)
    // MARK: Layout TextView
    func setupSubviewsLayout(direction: Direction) {
        
        let insetFromScreen = contentView.bounds.size.width * CGFloat((1 - MessageCell.messageToScreenRatio))
        
        switch direction {
        case .left:
            textView.snp.remakeConstraints { make in
                make.left.top.equalTo(contentView).inset(MessageCell.textPadding + MessageCell.bubbleMargin)
                make.bottom.equalTo(contentView).inset(MessageCell.textPadding + MessageCell.bubbleMargin + MessageCell.timePadding * 2)
                make.right.lessThanOrEqualTo(contentView).inset(insetFromScreen)
            }
        case .right:
            textView.snp.remakeConstraints { make in
                make.right.top.equalTo(contentView).inset(MessageCell.textPadding + MessageCell.bubbleMargin)
                make.bottom.equalTo(contentView).inset(MessageCell.textPadding + MessageCell.bubbleMargin + MessageCell.timePadding * 2)
                make.left.greaterThanOrEqualTo(contentView).inset(insetFromScreen)
            }
        }
    }
}
