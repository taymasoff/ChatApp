//
//  ChatViewController+Elements.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

extension ChatViewController {
    func makeDefaultProfileImageView(initials: String = "") -> UIImageView {
        let imageView = UIImageView(image: AppAssets.image(.yellowCircle))
        let button = UIButton(type: .custom)
        button.titleLabel?.font = AppAssets.font(.sfProDisplay, type: .regular, size: 18)
        button.setTitle(initials, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self,
                         action: #selector(profileBarButtonPressed),
                         for: .touchUpInside)
        imageView.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return imageView
    }
    
    func makeProfileBarButton(imageView: UIImageView) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(customView: imageView)
        barButton.target = self
        barButton.action = #selector(self.profileBarButtonPressed)
        barButton.customView?.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        return barButton
    }
    
    func makeGearBarButton() -> UIBarButtonItem {
        let barButton = UIBarButtonItem(
            image: AppAssets.image(.gear),
            style: .plain,
            target: self,
            action: #selector(gearBarButtonPressed))
        barButton.tintColor = AppAssets.colors(.barItemGray)
        return barButton
    }
}
