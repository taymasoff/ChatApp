//
//  ProfileViewController+Elements.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 28.09.2021.
//

import UIKit

extension ProfileViewController {
    func makeCloseBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Close",
                               style: .done,
                               target: self,
                               action: #selector(closeBarButtonPressed))
    }
    
    func setLeftAlignTitleView(font: UIFont, text: String, textColor: UIColor) {
        guard let navFrame = navigationController?.navigationBar.frame else{
            return
        }
        
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: navFrame.width*3, height: navFrame.height))
        self.navigationItem.titleView = parentView
        
        let label = UILabel(frame: .init(x: parentView.frame.minX, y: parentView.frame.minY, width: parentView.frame.width, height: parentView.frame.height))
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = font
        label.textAlignment = .left
        label.textColor = textColor
        label.text = text
        
        parentView.addSubview(label)
    }
}
