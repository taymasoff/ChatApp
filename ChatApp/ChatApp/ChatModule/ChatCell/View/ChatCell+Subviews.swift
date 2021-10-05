//
//  ChatCell+Subviews.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import UIKit
import SnapKit

extension ChatCell {
    func makeCellHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }
    
    func makeTextVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }
    
    func makeNameDateHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }
    
    func makeProfileImageView() -> UIImageView {
        let imageView = UIImageView()
        
        
        return imageView
    }
    
    func makeOnlineIndicatorView() -> UIView {
        let view = UIView()
        
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let label = UILabel()
        
        return label
    }
    
    func makeLastMessageLabel() -> UILabel {
        let label = UILabel()
        
        return label
    }
    
    func makeDateLabel() -> UILabel {
        let label = UILabel()
        
        return label
    }
}
