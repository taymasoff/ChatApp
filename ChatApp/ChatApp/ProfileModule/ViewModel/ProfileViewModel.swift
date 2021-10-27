//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol ProfileDelegate {
    func didUpdateProfileAvatar(with info: ProfileAvatarUpdateInfo?)
}

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

    var delegate: ProfileDelegate?

    let operationState: Dynamic<OperationState?> = Dynamic(nil)
    
    var persistenceManager: PersistenceManagerProtocol
    
    // MARK: - Init
    init(router: MainRouterProtocol,
         persistenceManager: PersistenceManagerProtocol? = nil,
         delegate: ProfileDelegate? = nil) {
        self.router = router
        self.persistenceManager = persistenceManager ?? PersistenceManager()
        self.delegate = delegate
        
        self.userName = DynamicPreservable(
            "", id: AppFileNames.userName.rawValue
        )
        self.userDescription = DynamicPreservable(
            "", id: AppFileNames.userDescription.rawValue
        )
        self.userAvatar = DynamicPreservable(
            nil, id: AppFileNames.userAvatar.rawValue
        )
    }
    
    // MARK: - Action Methods
    func editProfileImagePressed(sender: UIViewController) {
        ImagePickerManager().pickImage(sender) { [weak self] image in
            self?.userAvatar.value = image
        }
    }
    
    func saveButtonPressed() {
        saveCurrentUIState()
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
            saveUserName { [weak self] result in
                if let self = self {
                    if case .success = result {
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
            saveUserDescription { [weak self] result in
                if let self = self {
                    if case .success = result {
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
            saveUserAvatar { [weak self] result in
                if let self = self {
                    if case .success = result {
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
                if case .failure = dict.value {
                    message.append("Не удалось сохранить запись с ключом: \(dict.key)")
                } else {
                    message.append("Успешно сохранена запись с ключом: \(dict.key)")
                }
                message.append("\n")
            }
            
        }
        
        func containsError(_ results: [String: Result<Bool, Error>]) -> Bool {
            return results.contains(where: { _, value in
                if case .failure = value { return true } else { return false }
            })
        }
    }
}

// MARK: - Profile Delegate Notify Methods
private extension ProfileViewModel {
    // Метод вызывается после успешного сохранения аватарки
    // Если аватарка не пустая - передаем ее делегату
    private func notifyDelegateOnAvatarSave() {
        if let avatar = userAvatar.value {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didUpdateProfileAvatar(with: .avatar(avatar))
            }
        }
    }
    
    // Метод вызывается после успешного сохранения имени
    // Если аватарка пустая (т.е. нужен плейсхолдер) передаем имя
    // (имя нужно для генерации плейсхолдера с инициалами)
    private func notifyDelegateOnNameSave() {
        if let name = userName.value, userAvatar.value == nil {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didUpdateProfileAvatar(with: .name(name))
            }
        }
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
                    self?.userName.setAndPreserve(text)
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
                    self?.userDescription.setAndPreserve(text)
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
                    self?.userAvatar.setAndPreserve(image)
                }
            case .failure(let error):
                PMLog.error("Загрузка аватарки пользователя не удалась: \(error)")
            }
        }
    }
    
    // MARK: SaveUserName to Persistent Storage
    func saveUserName(completion: @escaping CompletionHandler<Bool>) {
        persistenceManager.save(userName.value ?? "",
                                key: userName.id) { [weak self] result in
            
            if case .success = result {
                self?.notifyDelegateOnNameSave()
                AppData.currentUserName = self?.userName.value ?? AppData.defaultUserName
            }
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
                                key: userAvatar.id) { [weak self] result in
            if case .success = result {
                self?.notifyDelegateOnAvatarSave()
            }
            completion(result)
        }
    }
}
