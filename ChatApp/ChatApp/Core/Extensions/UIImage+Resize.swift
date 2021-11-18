//
//  UIImage+ResizeImage.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import UIKit

/*
 👉 Простая функция для ресайзинга изображения
 */

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
