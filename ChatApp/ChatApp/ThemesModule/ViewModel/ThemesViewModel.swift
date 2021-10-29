//
//  ThemesViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 11.10.2021.
//

import UIKit

/// Вью-модель экрана выбора тем
final class ThemesViewModel: NSObject, Routable {

    var router: MainRouterProtocol
    var persistenceManager: PersistenceManagerProtocol?
    
    struct ViewData {
        var previewBackgroundColor: UIColor
        var previewTitleLabelTextColor: UIColor
        var previewSubtitleLabelTextColor: UIColor
        var previewTitleText: String
        var previewSubtitleText: String
        
        init(with selectedTheme: Theme = .defaultLight) {
            previewBackgroundColor = selectedTheme.settings.backGroundColor
            previewTitleLabelTextColor = selectedTheme.settings.titleTextColor
            previewSubtitleLabelTextColor = selectedTheme.settings.subtitleTextColor
            previewTitleText = selectedTheme.rawValue
            previewSubtitleText = "Subtitle example..."
        }
    }
    
    lazy var viewData: Dynamic<ViewData> = Dynamic(ViewData())
    
    private lazy var selectedTheme: Theme = .defaultLight {
        didSet {
            viewData.value = ViewData(with: selectedTheme)
        }
    }
    
    private var onThemeChanged: (UIColor) -> Void
    
    init(router: MainRouterProtocol,
         onThemeChanged: @escaping (UIColor) -> Void,
         persistenceManager: PersistenceManagerProtocol? = nil) {
        self.router = router
        self.onThemeChanged = onThemeChanged
        self.persistenceManager = persistenceManager
        super.init()
        
        // Просто для вывода в консоль
        loadThemeUsingPersistenceManager()
    }
    
    func didConfirmTheme() {
        saveThemeUsingPersistenceManager()
        ThemeManager.storedTheme = selectedTheme
        onThemeChanged(selectedTheme.settings.backGroundColor)
        
        askToReset()
    }
    
    func didDismissThemesView() { }
    
    private func askToReset() {
        let alert = UIAlertController(title: "Обновить тему?", message: "Чтобы обновить тему, необходимо перезагрузить экраны. \nНесохраненные состояния могут быть потеряны. \nВ ином случае, тема сменится после следующего рестарта приложения.", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Обновить тему сейчас",
                                         style: .default) { [weak self] _ in
            ThemeManager.updateCurrentTheme()
            self?.router.resetToUpdateTheme()
        }
        
        let declineAction = UIAlertAction(title: "Обновить тему потом",
                                          style: .cancel, handler: nil)
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        router.presentAlert(alert, animated: true)
    }
    
    private func saveThemeUsingPersistenceManager() {
        persistenceManager?.save(
            selectedTheme,
            key: ThemeManager.themeKey
        ) { [weak self] result in
            switch result {
            case .success(_):
                PMLog.info("Успешно сохранена тема: \(self?.selectedTheme.rawValue ?? "")")
            case .failure(let error):
                PMLog.error("Не удалось сохранить тему. Ошибка: \(error)")
            }
        }
    }
    
    private func loadThemeUsingPersistenceManager() {
        persistenceManager?.fetchModel(key: ThemeManager.themeKey)
        { (result: Result<Theme, Error>) in
            switch result {
            case .success(let model):
                PMLog.info("Загружена тема - \(model.rawValue)")
            case .failure(let error):
                PMLog.error("Ошибка загрузки темы - \(error)")
            }
        }
    }
}

// MARK: - PickerViewMethods
extension ThemesViewModel {
    func numberOfComponents() -> Int {
        return 1
    }
    
    func numberOfRows(in component: Int) -> Int {
        return Theme.allCases.count
    }
    
    func title(for row: Int, in component: Int) -> String? {
        return Theme.allCases[row].rawValue.capitalized
    }
    
    func didSelect(row: Int, in component: Int) {
        selectedTheme = Theme.allCases[row]
    }
}
