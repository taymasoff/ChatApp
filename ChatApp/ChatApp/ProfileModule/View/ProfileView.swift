//
//  ProfileView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.09.2021.
//

import UIKit
import SnapKit

class ProfileView: UIView {
    var profileImageView: UIImageView!
    var userNameLabel: UILabel!
    var userDescription: UITextView!
    var setImageButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        backgroundColor = AppAssets.colors(.appMain)
        profileImageView = makeProfileImageView()
        userNameLabel = makeUserNameLabel()
        userDescription = makeUserDescription()
        setImageButton = makeSetImageButton()
    }
}

// MARK: - ProfileView Subviews Setup

private extension ProfileView {
    func makeProfileImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        imageView.snp.makeConstraints { [unowned self] make in
            make.size.equalTo(self.frame.size.width / 2)
            make.centerY.equalTo(self.snp.top)
            make.centerX.equalTo(self.snp.centerX)
        }
        // Перерисовываем фреймы, чтобы получить ширину фрейма imageView
        self.layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true
        return imageView
    }
    
    func makeUserNameLabel() -> UILabel {
        let label = UILabel()
        label.font = AppAssets.font(.sfProDisplay, type: .semibold, size: 26)
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(profileImageView.snp.bottom).offset(40)
        }
        return label
    }
    
    func makeUserDescription() -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = AppAssets.font(.sfProText, type: .regular, size: 20)
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.top.equalTo(userNameLabel.snp.bottom).offset(40)
            make.bottom.equalToSuperview().inset(40)
        }
        return textView
    }
    
    func makeSetImageButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor = .systemBlue
        button.setImage(AppAssets.image(.camera), for: .normal)
        // Если добавить к ImageView, то углы срежутся, поэтому поверх
        addSubview(button)
        // Формула для нахождения точки на окружности
        let radius = profileImageView.frame.size.width / 2
        let xCoord = radius * sin(45 * (Double.pi / 180))
        let yCoord = radius * cos(45 * (Double.pi / 180))
        button.snp.makeConstraints { make in
            make.size.equalTo(profileImageView.snp.size).dividedBy(5)
            make.centerX.equalTo(profileImageView.snp.centerX).offset(xCoord)
            make.centerY.equalTo(profileImageView.snp.centerY).offset(yCoord)
        }
        button.imageView?.snp.makeConstraints { make in
            make.edges.equalTo(button.snp.edges).inset(8)
        }
        button.layer.cornerRadius = button.frame.size.width / 2
        return button
    }
}
