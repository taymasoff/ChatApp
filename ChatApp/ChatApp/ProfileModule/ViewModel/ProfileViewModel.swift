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
}

// MARK: - Load/Save UI Data
extension ProfileViewModel {
    // MARK: LoadLastUIStateFromStorage
    func loadLastUIStateFromPersistentStorage() {
        loadUserName()
        loadUserDescription()
        loadUserAvatar()
    }
    
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
    
    // MARK: Save All
    func saveCurrentUIState() {
        if userName.hasChanged() {
            saveUserName()
        } else {
            Log.pm("Имя пользователя не изменилось, оставляю без изменений.")
        }
        
        if userDescription.hasChanged() {
            saveUserDescription()
        } else {
            Log.pm("Описание пользователя не изменилось, оставляю без изменений.")
        }
        
        if userAvatar.value != nil, userAvatar.hasChanged() {
            saveUserAvatar()
        } else {
            Log.pm("Аватарка пользователя не изменилась или пустая, оставляю без изменений.")
        }
    }
    
    // MARK: SaveUserName to Persistent Storage
    func saveUserName() {
        persistenceManager.save(userName.value ?? "",
                                key: userName.id) { [weak self] result in
            switch result {
            case .success(_):
                Log.pm("Успешно сохранено: Имя пользователя. Имя файла: \(self?.userName.id ?? "Неизвестно")")
                self?.userName.preserve()
            case .failure(let error):
                Log.pm("Не удалось сохранить: Имя пользователя: \(error)")
            }
        }
    }
    
    // MARK: SaveUserDescription to Persistent Storage
    func saveUserDescription() {
        persistenceManager.save(userDescription.value ?? "",
                                key: userDescription.id) { [weak self] result in
            switch result {
            case .success(_):
                Log.pm("Успешно сохранено: Описание пользователя. Имя файла: \(self?.userDescription.id ?? "Неизвестно")")
                self?.userDescription.preserve()
            case .failure(let error):
                Log.pm("Не удалось сохранить: Описание пользователя: \(error)")
            }
        }
    }
    
    // MARK: SaveUserAvatar to Persistent Storage
    func saveUserAvatar() {
        guard let avatar = userAvatar.value else { return }
        persistenceManager.save(avatar,
                                key: userAvatar.id) { [weak self] result in
            switch result {
            case .success(_):
                Log.pm("Успешно сохранено: Аватар пользователя. Имя файла: \(self?.userAvatar.id ?? "Неизвестно")")
                self?.userAvatar.preserve()
            case .failure(let error):
                Log.pm("Не удалось сохранить: Аватар пользователя: \(error)")
            }
        }
    }
}
