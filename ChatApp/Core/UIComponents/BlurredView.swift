//
//  BlurredView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.09.2021.
//

import UIKit

/// UIVisualEffectView с эффектом блура
class BlurredView: UIVisualEffectView {
    
    /// Интенсивность блура
    enum BlurIntensity: Double {
        case light = 0.1
        case medium = 0.45
        case strong = 0.9
    }
    
    var animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    private var styleEffect: UIBlurEffect.Style
    private var effectIntensity: BlurIntensity
    
    // MARK: - Initializers
    init(effect: UIBlurEffect.Style = .dark, intensity: BlurIntensity = .light) {
        self.styleEffect = effect
        self.effectIntensity = intensity
        super.init(effect: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        backgroundColor = .clear
        frame = superview.bounds
        setupBlur()
    }
    
    private func setupBlur() {
        animator.stopAnimation(true)
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            self.effect = UIBlurEffect(style: self.styleEffect)
        }
        animator.fractionComplete = effectIntensity.rawValue
    }
    
    deinit {
        animator.stopAnimation(true)
    }
}
