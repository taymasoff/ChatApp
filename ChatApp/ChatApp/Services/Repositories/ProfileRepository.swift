//
//  ProfileRepository.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import UIKit

typealias ProfileRepositoryFMSupportable = FMStringOperatable & FMImageOperatable & FMRemoveSupportable

final class ProfileRepository: ProfileRepositoryProtocol, ProfileRepositoryFMSupportable {
    
    enum PRError: Error { case nothingSaved, failedToComposeSummary, failedToSave, failedToFetch }
    
    // MARK: - Properties
    let fileManager: AsyncFileManagerProtocol
    let fmPreferences: FileManagerPreferences
    let user: Dynamic<User?> = Dynamic(nil)
    
    // MARK: - Init
    init(fileManager: AsyncFileManagerProtocol = GCDFileManager(),
         fmPreferences: FileManagerPreferences = FileManagerPreferences(
            textExtension: .txt,
            imageExtension: .jpeg(1.0),
            directory: .userProfile)
    ) {
        self.fileManager = fileManager
        self.fmPreferences = fmPreferences
    }
}

// MARK: - Save User Separately Method
extension ProfileRepository {
    
    /*
     Операция по загрузке пользователя
     Проверяем поля юзера, те что изменены отправляем на сохранение,
     по завершению каждого, записываем результат в один из массивов:
     successOperations или failedOperations и добавляем результаты в новую модель userResult.
     По завершению всех операций суммаризируем сообщения, возвращаем результат
     в виде enumа OperationSuccess(allGood/hadErrors) вью-модели и обновляем модель пользователя
     */
    func saveUserSeparately(_ user: User,
                            completion: @escaping ResultHandler<OperationSuccess>) {
        
        let savingGroup = DispatchGroup()
        var successOperations = [String]()
        var failedOperations = [String]()
        
        if self.user.value?.name != user.name {
            savingGroup.enter()
            save(user.name, key: AppFileNames.userName.rawValue) { result in
                switch result {
                case .success:
                    successOperations.append("Успешно сохранено имя пользователя.")
                case .failure(let error):
                    failedOperations.append("Не удалось сохранить имя пользователя: \(error.localizedDescription)")
                }
                savingGroup.leave()
            }
        }
        
        if self.user.value?.description != user.description {
            savingGroup.enter()
            save(user.description, key: AppFileNames.userDescription.rawValue) { result in
                switch result {
                case .success:
                    successOperations.append("Успешно сохранено описание пользователя.")
                case .failure(let error):
                    failedOperations.append("Не удалось сохранить описание пользователя: \(error.localizedDescription)")
                }
                savingGroup.leave()
            }
        }
        
        if self.user.value?.avatar != user.avatar {
            savingGroup.enter()
            save(user.avatar, key: AppFileNames.userAvatar.rawValue) { result in
                switch result {
                case .success:
                    successOperations.append("Успешно сохранен аватар пользователя.")
                case .failure(let error):
                    failedOperations.append("Не удалось сохранить аватар пользователя: \(error.localizedDescription)")
                }
                savingGroup.leave()
            }
        }
        
        savingGroup.notify(queue: .main) { [weak self] in
            guard !successOperations.isEmpty || !failedOperations.isEmpty else {
                completion(.failure(PRError.nothingSaved))
                return
            }
            
            if let summarizedOperation = self?.summarizeOperation(
                successMessages: successOperations,
                failMessages: failedOperations
            ) {
                completion(.success(summarizedOperation))
                self?.user.value = user
            } else {
                completion(.failure(PRError.failedToComposeSummary))
            }
        }
    }
}

// MARK: - Fetch User Method
extension ProfileRepository {
    
    /*
     Стакаем несколько операций по загрузке, по завершению каждой из которых записываем результат в один из массивов successOperations или failedOperations
     По завершению всех 3 операций суммаризируем сообщения и возвращаем результат в виде enumа OperationSuccess(allGood/hadErrors) вью-модели
     Еще обновляем модель юзера с теми полями, что удалось загрузить - вью-модель на нее подписана
     */
    func fetchUser(completion: @escaping ResultHandler<OperationSuccess>) {
        
        let loadingGroup = DispatchGroup()
        var successOperations = [String]()
        var failedOperations = [String]()
        var userResult = User()
        
        loadingGroup.enter()
        fetchString(key: AppFileNames.userName.rawValue) { result in
            switch result {
            case .success(let name):
                successOperations.append("Успешно загружено имя пользователя: \(name)")
                userResult.name = name
            case .failure(let error):
                failedOperations.append("Не удалось загрузить имя пользователя: \(error.localizedDescription)")
                userResult.name = ""
            }
            loadingGroup.leave()
        }
        
        loadingGroup.enter()
        fetchString(key: AppFileNames.userDescription.rawValue) { result in
            switch result {
            case .success(let description):
                successOperations.append("Успешно загружено описание пользователя: \(description)")
                userResult.description = description
            case .failure(let error):
                failedOperations.append("Не удалось загрузить описание пользователя: \(error.localizedDescription)")
                userResult.description = ""
            }
            loadingGroup.leave()
        }
        
        loadingGroup.enter()
        fetchImage(key: AppFileNames.userAvatar.rawValue) { result in
            switch result {
            case .success(let avatar):
                successOperations.append("Успешно загружена аватарка пользователя")
                userResult.avatar = avatar
            case .failure(let error):
                failedOperations.append("Не удалось загрузить аватарку пользователя: \(error.localizedDescription)")
            }
            loadingGroup.leave()
        }
        
        loadingGroup.notify(queue: .main) { [weak self] in
            guard !successOperations.isEmpty || !failedOperations.isEmpty else {
                completion(.failure(PRError.failedToFetch))
                return
            }
            
            if let summarizedOperation = self?.summarizeOperation(
                successMessages: successOperations,
                failMessages: failedOperations
            ) {
                completion(.success(summarizedOperation))
            } else {
                completion(.failure(PRError.failedToComposeSummary))
            }
            
            self?.user.value = userResult
        }
    }
}

// MARK: - Summarize Operation
extension ProfileRepository {

    /// Подводит итог операций
    /// - Parameters:
    ///   - succesMessages: список успешных операций
    ///   - failMessages: список проваленных операций
    /// - Returns: enum с успехом или ошибками
    private func summarizeOperation(successMessages: [String],
                                    failMessages: [String]) -> OperationSuccess {
        let summarizedMessage = [successMessages, failMessages].reduce(into: "") {
            $0.append($1.joined(separator: "\n"))
        }

        if !failMessages.isEmpty {
            return .hadErrors(summarizedMessage)
        } else {
            return .allGood(summarizedMessage)
        }
    }
}
