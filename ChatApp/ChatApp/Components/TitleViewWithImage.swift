//
//  DMTitleView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.10.2021.
//

import UIKit
import SnapKit

final class TitleViewWithImage: UIView {
    static let imageHeight = 35
    
    // MARK: - Properties
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ThemeManager.currentTheme.settings.titleTextColor
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.setContentCompressionResistancePriority(UILayoutPriority(100),
                                                      for: .horizontal)
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                  width: Self.imageHeight,
                                                  height: Self.imageHeight))
        imageView.layer.cornerRadius = CGFloat(Self.imageHeight / 2)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.size.equalTo(Self.imageHeight)
        }
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    convenience init(with image: UIImage, title: String?) {
        self.init(frame: CGRect.zero)
        setupSubviews()
        updateUsing(image: image, title: title)
    }
    
    convenience init(with title: String?, placeholderType: PlaceholderType) {
        self.init(frame: CGRect.zero)
        setupSubviews()
        updateUsing(title: title, placeholderType: placeholderType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUsing(title: String?, placeholderType: PlaceholderType) {
        titleLabel.text = title
        switch placeholderType {
        case .forPerson:
            imageView.addProfilePlaceholder(fullName: title)
        case .forGroupChat:
            imageView.addAbbreviatedPlaceholder(text: title)
        }
    }
    
    func updateUsing(image: UIImage, title: String?) {
        titleLabel.text = title
        imageView.image = image
    }
    
    // MARK: - Setup Subviews
    private func setupSubviews() {
        backgroundColor = .clear
        
        self.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        self.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.8)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
    }
}
