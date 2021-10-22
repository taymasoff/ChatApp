//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 11.10.2021.
//

import UIKit
import SnapKit

/// Контроллер экрана выбора тем
final class ThemesViewController: UIViewController, ViewModelBased {
    
    private lazy var blurredView = BlurredView()
    private var themesView: ThemesView!

    var viewModel: ThemesViewModel?
    
    convenience init(with viewModel: ThemesViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        themesView = makeThemesView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesturesAndActions()
        themesView.themesPickerView.delegate = self
        themesView.themesPickerView.dataSource = self
        bindWithViewModel()
    }
    override func viewDidAppear(_ animated: Bool) {
        view.insertSubview(blurredView, at: 0)
        showThemesView()
    }
    
    // MARK: - Private Methods
    // MARK: Gesture Recognizers Methods
    private func setupGesturesAndActions() {
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(didSwipeThemesViewDown)
        )
        swipeDown.direction = .down
        themesView.addGestureRecognizer(swipeDown)
        
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTapOutsideThemesView))
        )
        themesView.confirmButton.addTarget(self,
                                           action: #selector(didTapConfirmThemeButton),
                                           for: .touchUpInside)
    }
    
    @objc
    private func didTapConfirmThemeButton() {
        viewModel?.didConfirmTheme()
    }
    
    @objc
    fileprivate func didTapOutsideThemesView() {
        dismissThemesView(animated: true) { [weak self] in
            self?.viewModel?.didDismissThemesView()
            self?.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc
    fileprivate func didSwipeThemesViewDown() {
        dismissThemesView(animated: true) { [weak self] in
            self?.viewModel?.didDismissThemesView()
            self?.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Show/Dismiss ThemesView Methods
    private func showThemesView(animated: Bool = true) {
        themesView.snp.remakeConstraints { make in
            make.bottom.right.left.equalToSuperview()
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
    
    private func dismissThemesView(animated: Bool = true,
                                   completion: @escaping () -> Void) {
        view.endEditing(true) // Убираем клавиатуру если она есть
        themesView.snp.remakeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) { [weak self] in
                self?.view.layoutIfNeeded()
            } completion: { _ in
                completion()
            }
        } else {
            view.layoutIfNeeded()
            completion()
        }
    }
    
    private func bindWithViewModel() {
        viewModel?.viewData.bind(listener: { [unowned self] viewData in
            themesView.previewView.backgroundColor = viewData.previewBackgroundColor
            themesView.previewTitleLabel.textColor = viewData.previewTitleLabelTextColor
            themesView.previewTitleLabel.text = viewData.previewTitleText
            themesView.previewSubtitleLabel.textColor = viewData.previewSubtitleLabelTextColor
            themesView.previewSubtitleLabel.text = viewData.previewSubtitleText
        })
    }
}

// MARK: - UIPickerViewDataSource
extension ThemesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.numberOfRows(in: component) ?? 0
    }
}

// MARK: - UIPickerViewDelegate
extension ThemesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return viewModel?.title(for: row, in: component)
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        viewModel?.didSelect(row: row, in: component)
    }
}

// MARK: - Setup Subviews Methods
private extension ThemesViewController {
    func makeThemesView() -> ThemesView {
        let themesView = ThemesView(frame: view.frame)
        view.addSubview(themesView)
        // Скругляем верхние углы
        themesView.layer.cornerRadius = themesView.frame.size.width / 10
        themesView.layer.maskedCorners = [.layerMaxXMinYCorner,
                                            .layerMinXMinYCorner]
        // Создаем констрейнты за пределами экрана для анимации
        themesView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        themesView.confirmButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(40 + view.safeAreaInsets.bottom)
        }
        return themesView
    }
}
