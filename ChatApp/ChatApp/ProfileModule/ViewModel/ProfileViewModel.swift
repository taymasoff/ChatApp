//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/// Вью-модель профиля
final class ProfileViewModel: Routable {
    
    enum OperationState {
        case loading
        case error(InAppNotificationViewModel)
        case success(InAppNotificationViewModel)
    }
    
    // MARK: - Properties
    let router: MainRouterProtocol
    
    let userName: DynamicPreservable<String?>
    let userDescription: DynamicPreservable<String?>
    let userAvatar: DynamicPreservable<UIImage?>
    
    let operationState: Dynamic<OperationState?> = Dynamic(nil)
    
    var persistenceManager: PersistenceManagerProtocol
    
    // MARK: - Init
    init(router: MainRouterProtocol,
         persistenceManager: PersistenceManagerProtocol = PersistenceManager()) {
        self.router = router
        self.persistenceManager = persistenceManager
        
        self.userName = DynamicPreservable("", id: "UserName")
        self.userDescription = DynamicPreservable("", id: "UserDescription")
        self.userAvatar = DynamicPreservable(nil, id: "UserAvatar")
    }
    
    // MARK: - Action Methods
    func editProfileImagePressed(sender: UIViewController) {
        ImagePickerManager().pickImage(sender) { [weak self] image in
            self?.userAvatar.value = image
        }
    }
    
    func saveButtonPressed() {
        askPreferredAsyncHandler()
    }
    
    func didDismissProfileView() {
        // Action on dismiss
    }
    
    // MARK: - LoadLastUIStateFromStorage
    func loadLastUIStateFromPersistentStorage() {
        loadUserName()
        loadUserDescription()
        loadUserAvatar()
    }
    
    // MARK: Save Changed UI To Persistent Storage
    func saveCurrentUIState() {
        operationState.value = .loading
        let savingGroup = DispatchGroup()
        var results = [String: Result<Bool, Error>]()
        
        if userName.hasChanged() {
            savingGroup.enter()
            saveUserName() { [weak self] result in
                if let self = self {
                    if case .success(_) = result {
                        DispatchQueue.main.async {
                            self.userName.preserve()
                        }
                    }
                    DispatchQueue.main.async {
                        results[self.userName.id] = result
                    }
                }
                savingGroup.leave()
            }
        } else {
            PMLog.info("Имя пользователя не изменилось, оставляю без изменений.")
        }
        
        if userDescription.hasChanged() {
            savingGroup.enter()
            saveUserDescription() { [weak self] result in
                if let self = self {
                    if case .success(_) = result {
                        DispatchQueue.main.async {
                            self.userDescription.preserve()
                        }
                    }
                    DispatchQueue.main.async {
                        results[self.userDescription.id] = result
                    }
                }
                savingGroup.leave()
            }
        } else {
            PMLog.info("Описание пользователя не изменилось, оставляю без изменений.")
        }
        
        if userAvatar.value != nil, userAvatar.hasChanged() {
            savingGroup.enter()
            saveUserAvatar() { [weak self] result in
                if let self = self {
                    if case .success(_) = result {
                        DispatchQueue.main.async {
                            self.userAvatar.preserve()
                        }
                    }
                    DispatchQueue.main.async {
                        results[self.userAvatar.id] = result
                    }
                }
                savingGroup.leave()
            }
        } else {
            PMLog.info("Аватарка пользователя не изменилась или пустая, оставляю без изменений.")
        }
        
        savingGroup.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Задержка 1 секунда
            savingGroup.leave()
        }
        
        savingGroup.notify(queue: .main) { [weak self] in
            guard !results.isEmpty else {
                self?.operationState.value = nil
                return
            }
            if containsError(results) {
                let inAppNotificationVM = InAppNotificationViewModel(
                    notificationType: .error,
                    headerText: "Произошла ошибка при сохранении",
                    bodyText: makeSummaryMessage(results),
                    buttonOneText: "Ok",
                    buttonTwoText: "Retry"
                )
                self?.operationState.value = .error(inAppNotificationVM)
            } else {
                let inAppNotificationVM = InAppNotificationViewModel(
                    notificationType: .success,
                    headerText: "Успешное сохранение",
                    bodyText: makeSummaryMessage(results),
                    buttonOneText: "Ok",
                    buttonTwoText: nil
                )
                self?.operationState.value = .success(inAppNotificationVM)
            }
        }
        
        func makeSummaryMessage(_ results: [String: Result<Bool, Error>]) -> String {
            return results.reduce(into: "") { message, dict in
                if case .failure(_) = dict.value {
                    message.append("Не удалось сохранить запись с ключом: \(dict.key)")
                } else {
                    message.append("Успешно сохранена запись с ключом: \(dict.key)")
                }
                message.append("\n")
            }
            
        }
        
        func containsError(_ results: [String: Result<Bool, Error>]) -> Bool {
            return results.contains(where: { key, value in
                if case .failure(_) = value { return true } else { return false }
            })
        }
    }
    
    private func askPreferredAsyncHandler() {
        let alert = UIAlertController(title: "Pick preferred async handler", message: nil, preferredStyle: .actionSheet)
        
        let gcdOption = UIAlertAction(title: "GCD",
                                      style: .default) { [weak self] _ in
            self?.persistenceManager.storageType.changeFMParameters(
                asyncHandler: .gcd
            )
            self?.saveCurrentUIState()
        }
        
        let operationOption = UIAlertAction(title: "Operations",
                                            style: .default) { [weak self] _ in
            self?.persistenceManager.storageType.changeFMParameters(
                asyncHandler: .operation(nil)
            )
            self?.saveCurrentUIState()
        }
        
        alert.addAction(gcdOption)
        alert.addAction(operationOption)
        
        router.presentAlert(alert, animated: true)
    }
}

// MARK: - Load/Save UI Data
private extension ProfileViewModel {
    
    // MARK: Load User Name
    func loadUserName() {
        persistenceManager
            .fetchString(key: userName.id) { [weak self] result in
            switch result {
            case .success(let text):
                DispatchQueue.main.async {
                    self?.userName.preserve(text)
                    self?.userName.value = text
                }
            case .failure(let error):
                PMLog.error("Загрузка имени пользователя не удалась: \(error)")
            }
        }
    }
    
    // MARK: Load User Description
    func loadUserDescription() {
        persistenceManager
            .fetchString(key: userDescription.id) { [weak self] result in
            switch result {
            case .success(let text):
                DispatchQueue.main.async {
                    self?.userDescription.preserve(text)
                    self?.userDescription.value = text
                }
            case .failure(let error):
                PMLog.error("Загрузка описания пользователя не удалась: \(error)")
            }
        }
    }
    
    // MARK: Load User Avatar
    func loadUserAvatar() {
        persistenceManager
            .fetchImage(key: userAvatar.id) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.userAvatar.preserve(image)
                    self?.userAvatar.value = image
                }
            case .failure(let error):
                PMLog.error("Загрузка аватарки пользователя не удалась: \(error)")
            }
        }
    }
    
    // MARK: SaveUserName to Persistent Storage
    func saveUserName(completion: @escaping CompletionHandler<Bool>) {
        persistenceManager.save(userName.value ?? "",
                                key: userName.id) { result in
            completion(result)
        }
    }
    
    // MARK: SaveUserDescription to Persistent Storage
    func saveUserDescription(completion: @escaping CompletionHandler<Bool>) {
        persistenceManager.save(userDescription.value ?? "",
                                key: userDescription.id) { result in
            completion(result)
        }
    }
    
    // MARK: SaveUserAvatar to Persistent Storage
    func saveUserAvatar(completion: @escaping CompletionHandler<Bool>) {
        guard let avatar = userAvatar.value else { return }
        persistenceManager.save(avatar,
                                key: userAvatar.id) { result in
            completion(result)
        }
    }
}
