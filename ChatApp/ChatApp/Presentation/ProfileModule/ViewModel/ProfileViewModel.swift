//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol ProfileDelegate: AnyObject {
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

    weak var delegate: ProfileDelegate?

    let operationState: Dynamic<OperationState?> = Dynamic(nil)
    
    private let repository: ProfileRepositoryProtocol
    private let imagePicker: ImagePickerManager
    
    // MARK: - Init
    init(router: MainRouterProtocol,
         repository: ProfileRepositoryProtocol? = nil,
         delegate: ProfileDelegate? = nil,
         imagePicker: ImagePickerManager = ImagePickerManager()) {
        self.router = router
        self.repository = repository ?? ProfileRepository()
        self.delegate = delegate
        self.imagePicker = imagePicker
        
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
    
    // MARK: - Bind to Repository Updates
    private func bindToRepositoryUpdates() {
        repository.user.bind { [unowned self] user in
            updateProperties(with: user)
        }
    }
    
    private func updateProperties(with user: User?) {
        guard let user = user else { return }
        userName.setAndPreserve(user.name)
        notifyDelegateOnNameSave()
        userDescription.setAndPreserve(user.description)
        if let image = user.avatar {
            userAvatar.setAndPreserve(image)
            notifyDelegateOnAvatarSave()
        }
    }
    
    // MARK: - Action Methods
    func editProfileImagePressed(sender: UIViewController,
                                 completion: @escaping () -> Void) {
        imagePicker.pickImage(sender) { [weak self] result in
            switch result {
            case .pickedLocalImage(let image):
                self?.userAvatar.value = image
            case .pickedImageOnline(let image, _):
                self?.userAvatar.value = image
            default:
                break
            }
            completion()
        }
    }
    
    func saveButtonPressed() {
        requestDataSaveIfChanged()
    }
    
    func didDismissProfileView() { }
    
    // MARK: - Request Repository to Update User
    func requestDataUpdate() {
        repository.fetchUser { _ in }
    }
    
    // MARK: - Request Repository to Save
    func requestDataSaveIfChanged() {
        if let user = groupValuesToModelIfAnyHasChanged() {
            operationState.value = .loading
            repository.saveUserSeparately(user) { [weak self] result in
                switch result {
                case .success(let operationResult):
                    self?.updateOperationState(with: operationResult)
                case .failure(let error):
                    self?.updateOperationState(with: error)
                }
            }
        } else {
            Log.info("Не было произведено никаких изменений. Ничего не сохранено.")
        }
    }
    
    func groupValuesToModelIfAnyHasChanged() -> User? {
        guard userName.hasChanged() || userDescription.hasChanged() || userAvatar.hasChanged() else {
            return nil
        }
        return User(
            name: userName.value,
            description: userDescription.value,
            avatar: userAvatar.value
        )
    }
    
    // MARK: Update OperationState
    private func updateOperationState(with result: OperationSuccess) {
        switch result {
        case .allGood(let message):
            let inAppNotificationVM = InAppNotificationViewModel(
                notificationType: .success,
                headerText: "Сохранение прошло успешно",
                bodyText: message,
                buttonOneText: "Ok"
            )
            operationState.value = .success(inAppNotificationVM)
        case .hadErrors(let message):
            let inAppNotificationVM = InAppNotificationViewModel(
                notificationType: .error,
                headerText: "Сохранение прошло с ошибками",
                bodyText: message,
                buttonOneText: "Ok",
                buttonTwoText: "Retry"
            )
            operationState.value = .error(inAppNotificationVM)
        }
    }
    
    // MARK: Update OperationState with Error
    private func updateOperationState(with error: Error) {
        let inAppNotificationVM = InAppNotificationViewModel(
            notificationType: .error,
            headerText: "Непредвиденная ошибка при сохранении",
            bodyText: error.localizedDescription,
            buttonOneText: "Ok"
        )
        operationState.value = .error(inAppNotificationVM)
    }
}

// MARK: - ProfileViewController Lifecycle Updates
extension ProfileViewModel {
    func viewDidLoad() {
        bindToRepositoryUpdates()
        requestDataUpdate()
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
        if let name = userName.value {
            AppData.currentUserName = name
            if userAvatar.value == nil {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didUpdateProfileAvatar(with: .name(name))
                }
            }
        }
    }
}
