//
//  MessageCell.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import UIKit

final class MessageCell: UITableViewCell, ConfigurableView {
    
    /// Направление расположения текстовых "баблов" в ячейке
    enum Direction {
        case left
        case right
    }
    
    // MARK: - Properties
    static let identifier = "MessageCell"
    
    static var textPadding: Int = 6
    static var bubbleMargin: Int = 12
    static var timePadding: Int = 8
    static var messageToScreenRatio: Float = 0.66
    
    var viewModel: MessageCellViewModelProtocol?
    
    var bgBubbleView: UIView!
    var textView: UITextView!
    var timeLabel: UILabel!
    
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
    
    // MARK: - Configuration
    func configure(with model: MessageCellViewModelProtocol?) {
        
        viewModel = model
        bindWithViewModel()
    }
    
    private func bindWithViewModel() {
        
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
    
    private func updateSubviews(direction: Direction) {
        switch direction {
        case .left:
            bgBubbleView.backgroundColor = AppAssets.colors(.dmGray)
        case .right:
            bgBubbleView.backgroundColor = AppAssets.colors(.dmGreen)
        }
        setupSubviewsLayout(direction: direction)
    }
}
