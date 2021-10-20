//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/// Вью-модель профиля
final class ProfileViewModel: Routable {
    
    // MARK: - Properties
    let router: MainRouterProtocol
    
    var userName: DynamicPreservable<String?>
    var userDescription: DynamicPreservable<String?>
    var userAvatar: DynamicPreservable<UIImage?>
    
    private(set) var isLoading: Dynamic<Bool> = Dynamic(false)
    private(set) var onError: Dynamic<String> = Dynamic("")
    private(set) var onSuccess: Dynamic<String> = Dynamic("")
    
    let persistenceManager: PersistenceManagerProtocol
    
    // MARK: - Init
    init(router: MainRouterProtocol,
         persistenceManager: PersistenceManagerProtocol = PersistenceManager()) {
        self.router = router
        self.persistenceManager = persistenceManager
        
        self.userName = DynamicPreservable(nil, id: "UserName")
        self.userDescription = DynamicPreservable(nil, id: "UserDescription")
        self.userAvatar = DynamicPreservable(nil, id: "UserAvatar")
    }
    
    // MARK: - Action Methods
    func editProfileImagePressed(sender: UIViewController) {
        ImagePickerManager().pickImage(sender) { [weak self] image in
            self?.userAvatar.value = image
        }
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
        isLoading.value = true
        let savingGroup = DispatchGroup()
        
        if userName.hasChanged() {
            saveUserName(group: savingGroup) { text in
                
            }
        } else {
            Log.pm("Имя пользователя не изменилось, оставляю без изменений.")
        }
        
        if userDescription.hasChanged() {
            saveUserDescription(group: savingGroup) { text in
                
            }
        } else {
            Log.pm("Описание пользователя не изменилось, оставляю без изменений.")
        }
        
        if userAvatar.value != nil, userAvatar.hasChanged() {
            saveUserAvatar(group: savingGroup) { text in
                
            }
        } else {
            Log.pm("Аватарка пользователя не изменилась или пустая, оставляю без изменений.")
        }
        
        savingGroup.notify(queue: .main) { [weak self] in
            self?.isLoading.value = false
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
                    self?.userName.preserve(text)
                    self?.userName.value = text
                }
            case .failure(let error):
                Log.pm("Загрузка имени пользователя не удалась: \(error)")
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
                Log.pm("Загрузка описания пользователя не удалась: \(error)")
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
                Log.pm("Загрузка аватарки пользователя не удалась: \(error)")
            }
        }
    }
    
    // MARK: SaveUserName to Persistent Storage
    func saveUserName(group: DispatchGroup? = nil,
                      completion: @escaping (String) -> Void) {
        guard let group = group else { return }
        group.enter()
        persistenceManager.save(userName.value ?? "",
                                key: userName.id) { [weak self] result in
            switch result {
            case .success(_):
                self?.userName.preserve()
                let successMessage = "Имя пользователя успешно сохранено. Имя записи: \(self?.userName.id ?? "Неизвестно")"
                Log.pm(successMessage)
                completion(successMessage)
            case .failure(let error):
                let failMessage = "Не удалось сохранить имя пользователя. Ошибка: \(error)"
                Log.pm(failMessage)
                completion(failMessage)
            }
            group.leave()
        }
    }
    
    // MARK: SaveUserDescription to Persistent Storage
    func saveUserDescription(group: DispatchGroup? = nil,
                             completion: @escaping (String) -> Void) {
        persistenceManager.save(userDescription.value ?? "",
                                key: userDescription.id) { [weak self] result in
            switch result {
            case .success(_):
                self?.userDescription.preserve()
                let successMessage = "Описание пользователя успешно сохранено. Имя записи: \(self?.userDescription.id ?? "Неизвестно")"
                Log.pm(successMessage)
                completion(successMessage)
            case .failure(let error):
                let failMessage = "Не удалось сохранить описание пользователя: \(error)"
                Log.pm(failMessage)
                completion(failMessage)
            }
        }
    }
    
    // MARK: SaveUserAvatar to Persistent Storage
    func saveUserAvatar(group: DispatchGroup? = nil,
                        completion: @escaping (String) -> Void) {
        guard let avatar = userAvatar.value else { return }
        persistenceManager.save(avatar,
                                key: userAvatar.id) { [weak self] result in
            switch result {
            case .success(_):
                self?.userAvatar.preserve()
                let successMessage = "Аватар пользователя успешно сохранен. Имя файла: \(self?.userAvatar.id ?? "Неизвестно")"
                Log.pm(successMessage)
                completion(successMessage)
            case .failure(let error):
                let failMessage = "Не удалось сохранить аватар пользователя: \(error)"
                Log.pm(failMessage)
                completion(failMessage)
            }
        }
    }
}
