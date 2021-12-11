//
//  PopupViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 19.11.2021.
//

import UIKit
import SnapKit

/// Переиспользуемый контроллер для работы со всплывающими сценами
class PopupViewController: UIViewController {
    
    enum PopupSize {
        /// Full screen popup
        case full
        /// 0.7 Screen multiplier
        case normal
        /// 0.4 Screen multiplier
        case small
        /// Custom multiplier 0.0 - 1.0
        case custom(CGFloat)
        /// View calculates hight itsself
        case selfCalculated
        
        var screenMultiplier: CGFloat? {
            switch self {
            case .full: return 1.0
            case .normal: return 0.7
            case .small: return 0.4
            case .custom(let size): return size
            case .selfCalculated: return nil
            }
        }
    }
    
    // MARK: - Properties
    private var blurredView: BlurredView
    private var popupView: UIView
    private var isPresented: Bool = false
    private var shapeCorners: Bool = true
    private var popupHeight: CGFloat {
        if let multiplier = popupSize.screenMultiplier {
            return view.frame.size.height * multiplier
        } else {
            return popupView.frame.size.height
        }
    }
    private(set) var popupSize: PopupSize
    
    // MARK: - Inits
    init(popupView: UIView, popupSize: PopupSize, shapeCorners: Bool = true) {
        self.popupView = popupView
        self.popupSize = popupSize
        self.shapeCorners = shapeCorners
        self.blurredView = BlurredView()
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(popupView: UIView,
                     popupSize: PopupSize,
                     blurredView: BlurredView) {
        self.init(popupView: popupView, popupSize: popupSize)
        self.blurredView = blurredView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.insertSubview(blurredView, at: 0)
        self.view.addSubview(popupView)
        setupPopupView()
        setupGesturesAndActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPopup { }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    // MARK: - Setup Methods
    private func setupGesturesAndActions() {
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(didSwipePopupDown)
        )
        swipeDown.direction = .down
        popupView.addGestureRecognizer(swipeDown)
        
        let tapOutside = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapOutsidePopup)
        )
        
        blurredView.addGestureRecognizer(tapOutside)
    }
    
    private func setupPopupView() {
        if shapeCorners { setCorners() }
        
        popupView.snp.remakeConstraints { make in
            make.right.left.equalToSuperview()
                .priority(UILayoutPriority(999))
            make.top.greaterThanOrEqualToSuperview()
                .priority(UILayoutPriority(999))
            if let screenMultiplier = popupSize.screenMultiplier {
                make.height.equalToSuperview().multipliedBy(screenMultiplier)
                    .priority(UILayoutPriority(999))
            }
            make.bottom.equalTo(view.snp.bottom)
                .offset(popupHeight)
                .priority(UILayoutPriority(999))
        }
        
        // Если высота не известна то сначала отрисовываем фрейм
        if popupSize.screenMultiplier == nil {
            view.layoutIfNeeded()
            popupView.snp.updateConstraints { make in
                make.bottom.equalTo(view.snp.bottom)
                    .offset(popupHeight)
                    .priority(UILayoutPriority(999))
            }
        }
        
        view.layoutIfNeeded()
    }
    
    private func setCorners() {
        popupView.layer.masksToBounds = true
        popupView.layer.cornerRadius = view.frame.size.width / 10
        popupView.layer.maskedCorners = [.layerMaxXMinYCorner,
                                         .layerMinXMinYCorner]
    }
    
    // MARK: - Action Methods
    @objc
    func didTapOutsidePopup() {
        dismissPopup(animated: true) { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc
    func didSwipePopupDown() {
        dismissPopup(animated: true) { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Show/Dismiss Methods
    func showPopup(animated: Bool = true,
                   completion: @escaping () -> Void) {
        if isPresented { completion(); return }
        popupView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
                .priority(UILayoutPriority(999))
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            } completion: { [weak self] _ in
                self?.isPresented = true
                completion()
            }
        } else {
            view.layoutIfNeeded()
            isPresented = true
            completion()
        }
    }
    
    func dismissPopup(animated: Bool = true,
                      completion: @escaping () -> Void) {
        view.endEditing(true)
        popupView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
                .offset(popupView.frame.height)
                .priority(UILayoutPriority(999))
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) { [weak self] in
                self?.view.layoutIfNeeded()
            } completion: { [weak self] _ in
                self?.isPresented = false
                completion()
            }
        } else {
            view.layoutIfNeeded()
            isPresented = false
            completion()
        }
    }
}

// MARK: - KeyboardObserving
extension PopupViewController: KeyboardObserving {
    
    func keyboardWillShow(keyboardSize: CGRect, duration: Double) {
        popupView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
                .offset(-keyboardSize.height)
                .priority(UILayoutPriority(999))
        }
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide(duration: Double) {
        popupView.snp.updateConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
                .priority(UILayoutPriority(999))
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
