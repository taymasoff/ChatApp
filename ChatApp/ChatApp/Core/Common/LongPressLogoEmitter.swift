//
//  LongPressLogoEmitter.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 01.12.2021.
//

import UIKit
import Rswift

/*
 👉 Создает множество гербов Тинькоф из под пальца при длинном нажатии.
 ⚙️ При инициализации задается drawingView. Это вьюшка, которая обрабатывает нажатие и отрисовывает логотипы.
 🔁 Жизненный цикл гербов регулируется через свойство lifetime эмитера.
 Судя по документации, при lifetime = 0 эмитер не рендерит ничего, т.е. ресурсы не тратятся.
 Такой подход мне нравится больше, чем удаление слоя, т.к. на экране остаются "догосающие" логотипы.
 ⬆️ При каждом нажатии проверяется, чтобы слой эмитера был поверх других слов, чтобы анимация всегда была видна.
 */

final class LongPressLogoEmitter {
    private static let logoLifetime: Float = 1.5
    
    // MARK: - Properties
    private lazy var emitterCell: CAEmitterCell = {
        let cell = CAEmitterCell()
        cell.contents = R.image.tinkoffTinyLogo()?.cgImage
        cell.contentsScale = 3
        cell.birthRate = 18
        cell.emissionRange = .pi
        cell.lifetime = Self.logoLifetime
        cell.lifetimeRange = Self.logoLifetime / 3
        cell.alphaSpeed = -0.5
        cell.velocity = 80
        return cell
    }()
    
    private lazy var emitterLayer: CAEmitterLayer = {
        let layer = CAEmitterLayer()
        layer.emitterSize = CGSize(width: 1, height: 1)
        layer.emitterShape = .circle
        layer.emitterCells = [emitterCell]
        layer.lifetime = 0
        return layer
    }()
    
    /// Вьюшка на которой рисуются логотипы и обрабатываются нажатия
    private weak var drawingView: UIView?
    
    /// Gesture Recognizer, на который реагирует эмитер
    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress)
        )
    }()
    
    /// Текущее состояние эмитера
    private(set) var isEnabled: Bool = false
    
    // MARK: - Initializer
    init(drawingView: UIView) {
        self.drawingView = drawingView
        self.emitterLayer.lifetime = 0
        self.drawingView?.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // MARK: - TurnOn/TurnOff
    func enable() {
        guard !isEnabled else {
            print("Logo emitter already enabled")
            return
        }
        self.longPressGestureRecognizer.isEnabled = true
        self.drawingView?.layer.addSublayer(emitterLayer)
        self.isEnabled = true
    }
    
    func disable() {
        guard isEnabled else {
            print("Logo emitter already disabled")
            return
        }
        self.longPressGestureRecognizer.isEnabled = false
        emitterLayer.removeFromSuperlayer()
        self.isEnabled = false
    }
    
    // MARK: - GestureHandler
    @objc
    private func handleLongPress(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            makeSureEmitterLayerIsOnTop()
            emitterLayer.lifetime = Self.logoLifetime
            emitterLayer.emitterPosition = sender.location(in: drawingView)
        case .changed:
            emitterLayer.emitterPosition = sender.location(in: drawingView)
        default:
            emitterLayer.lifetime = 0
        }
    }
    
    /// Проверяет, чтобы слой эмитера был "видимым". Если это не так - переставляет его
    private func makeSureEmitterLayerIsOnTop() {
        if drawingView?.layer.sublayers?.last != emitterLayer {
            self.drawingView?.layer.bringSublayerToFront(emitterLayer)
        }
    }
}

private extension CALayer {
    
    /// Перемещает переданный слой поверх иерархии слоев текущего слоя
    func bringSublayerToFront(_ sublayer: CALayer) {
        sublayer.removeFromSuperlayer()
        self.addSublayer(sublayer)
    }
}
