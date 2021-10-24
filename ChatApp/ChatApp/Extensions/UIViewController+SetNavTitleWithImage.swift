//
//  UIViewController+SetNavTitleWithImage.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 06.10.2021.
//

import UIKit
import SnapKit

/*
 👉 Заменяет Title ViewController'а на ProfileImage + Title
 */

extension UIViewController {
    func setNavTitleWithImage(title: String?, image: UIImage?) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = ThemeManager.currentTheme.settings.titleTextColor
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        
        let imageSize = CGFloat(34)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.contentMode = .scaleAspectFit
        if let image = image {
            imageView.image = image
        } else {
            imageView.addProfilePlaceholder(fullName: title)
        }
        
        let titleView = UIView()
        let container = UIView()
        titleView.addSubview(container)
        
        container.addSubview(imageView)
        container.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(34)
            make.centerY.equalToSuperview()

        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(10)
            make.centerY.equalTo(imageView)
        }
        
        container.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.left)
            make.top.bottom.equalTo(imageView).inset(5)
            make.right.equalTo(titleLabel.snp.right)
            make.center.equalToSuperview()
        }
        
        titleView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(UIScreen.main.bounds.width * 2 / 3)
        }
        
        navigationItem.titleView = titleView
    }
}
