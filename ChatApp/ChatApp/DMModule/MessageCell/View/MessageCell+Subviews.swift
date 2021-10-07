//
//  MessageCell+Subviews.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 06.10.2021.
//

import UIKit
import SnapKit

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
        textView.font = AppAssets.font(.sfProText, type: .regular, size: 16)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.textAlignment = .left
        return textView
    }
    
    func makeTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = AppAssets.font(.sfProText, type: .regular, size: 12)
        label.textColor = AppAssets.colors(.timeGray)
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
