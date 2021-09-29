//
//  BlurredView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.09.2021.
//

import UIKit

/*
 Эффект блура. Используется в ProfileViewController для 
 */

class BlurredView: UIVisualEffectView {
    
    var animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        backgroundColor = .clear
        frame = superview.bounds
        setupBlur()
    }
    
    private func setupBlur() {
        animator.stopAnimation(true)
        effect = nil

        animator.addAnimations { [weak self] in
            self?.effect = UIBlurEffect(style: .dark)
        }
        animator.fractionComplete = 0.1 // blur intensity
    }
    
    deinit {
        animator.stopAnimation(true)
    }
}
