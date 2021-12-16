//
//  ShakyButton.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 30.11.2021.
//

import UIKit

final class ShakyButton: UIButton {
    private static let shakyAnimationKey = "shakyAnimation"
    
    /// Находится ли кнопка в состоянии тряски
    private(set) var isShaking = false
    
    /// Начать анимацию тряски кнопки
    func startShaking() {
        guard !isShaking else { return }
        let shakyAnimation = makeShakyAnimation()
        layer.add(shakyAnimation, forKey: Self.shakyAnimationKey)
        isShaking = true
    }
    
    /// Завершить анимацию тряски кнопки
    func stopShaking() {
        guard isShaking else { return }
        let shakyAnimationFinisher = makeShakyAnimationFinisher()
        layer.removeAnimation(forKey: Self.shakyAnimationKey)
        layer.add(shakyAnimationFinisher, forKey: nil)
        isShaking = false
    }
}

private extension ShakyButton {
    
    /// Создает группу анимаций для тряски
    /// - Parameters:
    ///   - rotationAngle: угол на который отклоняется кнопка (по умолчанию 18 градусов)
    ///   - positionOffset: смещение позиции при тряске по x и y (по умолчанию 5)
    func makeShakyAnimation(rotationAngle: Double = 18 * Double.pi / 180,
                            positionOffset: CGFloat = 5) -> CAAnimationGroup {
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values = [0, -rotationAngle, 0, rotationAngle, 0]
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        let currentPosition = layer.position
        positionAnimation.values = [
            currentPosition,
            CGPoint(x: currentPosition.x - positionOffset, y: currentPosition.y),
            CGPoint(x: currentPosition.x, y: currentPosition.y - positionOffset),
            CGPoint(x: currentPosition.x + positionOffset, y: currentPosition.y),
            CGPoint(x: currentPosition.x, y: currentPosition.y + positionOffset)
        ]
        
        let group = CAAnimationGroup()
        group.duration = 0.3
        group.repeatCount = .infinity
        group.autoreverses = true
        group.fillMode = .both
        group.animations = [rotationAnimation, positionAnimation]
        return group
    }
    
    /// Создает группу анимаций для плавного завершения тряски (автоматически удаляется из слоя по завершении)
    func makeShakyAnimationFinisher() -> CAAnimationGroup {
        let rotationFinisher = CABasicAnimation(keyPath: "transform.rotation")
        rotationFinisher.fromValue = layer.presentation()?
            .value(forKeyPath: "transform.rotation") as? CGFloat
        rotationFinisher.toValue = 0
        
        let positionFinisher = CABasicAnimation(keyPath: "position")
        positionFinisher.fromValue = layer.presentation()?
            .value(forKeyPath: "position") as? CGPoint
        positionFinisher.toValue = layer.position
        
        let group = CAAnimationGroup()
        group.duration = 0.1 // 0.3 по ощущениям слишком долго
        group.fillMode = .both
        group.animations = [rotationFinisher, positionFinisher]
        group.isRemovedOnCompletion = true
        return group
    }
}
