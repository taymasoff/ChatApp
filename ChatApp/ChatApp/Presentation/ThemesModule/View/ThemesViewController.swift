//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 11.10.2021.
//

import UIKit
import SnapKit

/// Контроллер экрана выбора тем
final class ThemesViewController: PopupViewController, ViewModelBased {
    
    private var themesView: ThemesView

    var viewModel: ThemesViewModel?
    
    // MARK: - Inits
    required init(popupView: UIView, popupSize: PopupSize) {
        self.themesView = popupView as? ThemesView ?? ThemesView()
        super.init(popupView: popupView, popupSize: popupSize)
    }
    
    convenience init(with viewModel: ThemesViewModel,
                     themesView: ThemesView) {
        self.init(popupView: themesView, popupSize: .selfCalculated)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesturesAndActions()
        themesView.themesPickerView.delegate = self
        themesView.themesPickerView.dataSource = self
        restoreLastThemeSelection()
        bindWithViewModel()
    }
    
    // MARK: Gesture Recognizers Methods
    private func setupGesturesAndActions() {
        themesView.confirmButton.addTarget(self,
                                           action: #selector(didTapConfirmThemeButton),
                                           for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc
    private func didTapConfirmThemeButton() {
        viewModel?.didConfirmTheme()
    }
    
    // MARK: - Methods
    private func restoreLastThemeSelection() {
        let lastPickedThemeIndex = ThemeManager.currentTheme.selectedIndex
        pickerView(themesView.themesPickerView,
                   didSelectRow: lastPickedThemeIndex,
                   inComponent: 0
        )
        themesView.themesPickerView.selectRow(
            lastPickedThemeIndex,
            inComponent: 0,
            animated: false
        )
    }
}

// MARK: - ViewModelBindable
extension ThemesViewController: ViewModelBindable {
    func bindWithViewModel() {
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
