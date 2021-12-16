//
//  UIImage+Resize+CropRatio.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import UIKit

extension UIImage {
    var cropRatio: CGFloat {
        return CGFloat(self.size.width / self.size.height)
    }
    
    func resize(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
