//
//  ChatViewController+Subviews.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

extension ChatViewController {
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
