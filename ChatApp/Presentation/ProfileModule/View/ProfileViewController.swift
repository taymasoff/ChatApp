//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import SnapKit

final class ProfileViewController: PopupViewController, ViewModelBased {
    
    // MARK: - Properties
    lazy var inAppNotification = InAppNotificationBanner()
    private var profileView: ProfileView
    
    var viewModel: ProfileViewModel?
    lazy var nameFormatter = PersonNameComponentsFormatter()
    
    // MARK: - Inits
    init(profileView: ProfileView, popupSize: PopupSize) {
        self.profileView = profileView
        super.init(popupView: profileView, popupSize: popupSize)
    }
    
    convenience init(with viewModel: ProfileViewModel,
                     profileView: ProfileView) {
        self.init(profileView: profileView, popupSize: .custom(0.85))
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.userNameTextField.delegate = self
        profileView.userDescriptionTextView.delegate = self
        setupGestureRecognizers()
        
        bindWithViewModel()
        setSaveButtonState(.off)
        viewModel?.viewDidLoad()
    }

    // MARK: Setup Methods
    private func setupGestureRecognizers() {
        profileView.setImageButton.addTarget(
            self,
            action: #selector(editProfileImagePressed),
            for: .touchUpInside
        )
        
        profileView.addGestureRecognizer(UITapGestureRecognizer(
            target: profileView,
            action: #selector(UIView.endEditing(_:)))
        )
        
        profileView.profileImageUndoButton.addTarget(
            self,
            action: #selector(didTapProfileImageUndoButton),
            for: .touchUpInside
        )
        
        profileView.userNameUndoButton.addTarget(
            self,
            action: #selector(didTapUserNameUndoButton),
            for: .touchUpInside
        )
        
        profileView.userDescriptionUndoButton.addTarget(
            self,
            action: #selector(didTapUserDescriptionUndoButton),
            for: .touchUpInside
        )
        
        profileView.saveButton.addTarget(
            self,
            action: #selector(didTapSaveButton),
            for: .touchUpInside
        )
        
        profileView.userNameTextField.addTarget(self,
                                                action: #selector(nameTextFieldDidChange),
                                                for: .editingChanged)
    }
    
    // MARK: Action Methods
    @objc
    private func editProfileImagePressed() {
        profileView.setImageButton.startShaking()
        viewModel?.editProfileImagePressed(sender: self) { [weak self] in
            self?.profileView.setImageButton.stopShaking()
        }
    }
    
    @objc
    private func didTapProfileImageUndoButton() {
        viewModel?.userAvatar.restore()
        profileView.hideProfileUndoButton()
    }
    
    @objc
    private func didTapUserNameUndoButton() {
        viewModel?.userName.restore()
        profileView.hideNameUndoButton()
    }
    
    @objc
    private func didTapUserDescriptionUndoButton() {
        viewModel?.userDescription.restore()
        profileView.hideDescriptionUndoButton()
    }
    
    @objc
    private func didTapSaveButton() {
        viewModel?.saveButtonPressed()
        profileView.hideNameUndoButton()
        profileView.hideDescriptionUndoButton()
        profileView.hideProfileUndoButton()
        setSaveButtonState(.off)
    }
}

// MARK: - ViewModelBindable
extension ProfileViewController: ViewModelBindable {
    func bindWithViewModel() {
        // MARK: Bind userName to userNameTextField
        viewModel?.userName.bind(listener: { [unowned self] name in
            if self.viewModel?.userAvatar.value == nil {
                self.profileView.profileImageView.addProfilePlaceholder(fullName: name)
            }
            if self.profileView.userNameTextField.text != "" || self.profileView.userNameTextField.text != nil {
                animateImageViewChange()
            }
            self.profileView.userNameTextField.text = name
        })
        // MARK: Bind userDescription to userDescriptionTextField
        viewModel?.userDescription.bind(listener: { [unowned self] description in
            self.profileView.userDescriptionTextView.text = description
            if let description = description, description != "" {
                self.userDescriptionPlaceholderState(.off)
            } else {
                self.userDescriptionPlaceholderState(.on)
            }
        })
        // MARK: Bind userAvatar to profileImageView
        viewModel?.userAvatar.bind(listener: { [unowned self] image in
            if let image = image {
                // Если у нас был установлен placeholder,
                // удаляем его лейбл с инициалами
                if let initialsLabel = self.profileView.profileImageView.subviews.last as? UILabel {
                    initialsLabel.removeFromSuperview()
                }
                self.profileView.profileImageView.image = image
            } else {
                self.profileView.profileImageView.addProfilePlaceholder(
                    fullName: viewModel?.userName.value,
                    formattedBy: nameFormatter
                )
            }
        })
        // MARK: Bind userName Updates
        viewModel?.userName.bindUpdates(updatesListener: { [unowned self] isChanged in
            if isChanged {
                self.profileView.showNameUndoButton()
                self.setSaveButtonState(.on)
            } else {
                self.profileView.hideNameUndoButton()
                if let viewModel = self.viewModel,
                   !viewModel.userDescription.hasChanged(),
                   !viewModel.userAvatar.hasChanged() {
                    self.setSaveButtonState(.off)
                }
            }
        })
        // MARK: Bind userDescription Updates
        viewModel?.userDescription.bindUpdates(updatesListener: { [unowned self] isChanged in
            if isChanged {
                self.profileView.showDescriptionUndoButton()
                self.setSaveButtonState(.on)
            } else {
                self.profileView.hideDescriptionUndoButton()
                if let viewModel = self.viewModel,
                   !viewModel.userAvatar.hasChanged(),
                   !viewModel.userName.hasChanged() {
                    self.setSaveButtonState(.off)
                }
            }
        })
        // MARK: Bind userAvatar Updates
        viewModel?.userAvatar.bindUpdates(updatesListener: { [unowned self] isChanged in
            if isChanged {
                self.profileView.showProfileUndoButton()
                self.setSaveButtonState(.on)
            } else {
                self.profileView.hideProfileUndoButton()
                if let viewModel = self.viewModel,
                   !viewModel.userName.hasChanged(),
                   !viewModel.userDescription.hasChanged() {
                    self.setSaveButtonState(.off)
                }
            }
        })
        
        viewModel?.operationState.bind(listener: { [unowned self] operationState in
            switch operationState {
            case .loading:
                self.setViewLoadingState(.on)
            case .success(let vm):
                self.setViewLoadingState(.off)
                showSuccessNotification(vm)
            case .error(let vm):
                self.setViewLoadingState(.off)
                showErrorNotification(vm)
            case .none:
                self.setViewLoadingState(.off)
            }
        })
    }
}

// MARK: - State Reacting UI Changes
private extension ProfileViewController {
    enum ElementState { case on, off }
    
    // MARK: Loading State
    func setViewLoadingState(_ state: ElementState) {
        switch state {
        case .on:
            profileView.activityIndicator.startAnimating()
            profileView.setImageButton.isHidden = true
            profileView.userNameTextField.isEnabled = false
            profileView.userDescriptionTextView.isEditable = false
        case .off:
            profileView.activityIndicator.stopAnimating()
            profileView.setImageButton.isHidden = false
            profileView.userNameTextField.isEnabled = true
            profileView.userDescriptionTextView.isEditable = true
        }
    }
    
    // MARK: Loaded with Error -> Show Error Notification
    func showErrorNotification(_ vm: InAppNotificationViewModel) {
        inAppNotification.configure(with: vm)
        inAppNotification.show()
        inAppNotification.onButtonOnePress = { [weak self] in
            self?.inAppNotification.dismiss()
        }
        inAppNotification.onButtonTwoPress = { [weak self, weak viewModel] in
            viewModel?.requestDataSaveIfChanged()
            self?.inAppNotification.dismiss()
        }
    }
    
    // MARK: Loaded with Success -> Show Success Notification
    func showSuccessNotification(_ vm: InAppNotificationViewModel) {
        inAppNotification.configure(with: vm)
        inAppNotification.show()
        inAppNotification.onButtonOnePress = { [weak self] in
            self?.inAppNotification.dismiss()
        }
    }
    
    // MARK: Save Button State
    func setSaveButtonState(_ state: ElementState) {
        switch state {
        case .on:
            profileView.saveButton.isHidden = false
        case .off:
            profileView.saveButton.isHidden = true
        }
    }
    
    // MARK: UserDescriptionTextView Placeholder State
    func userDescriptionPlaceholderState(_ state: ElementState) {
        switch state {
        case .on:
            profileView.userDescriptionTextViewPlaceholder.isHidden = false
        case .off:
            profileView.userDescriptionTextViewPlaceholder.isHidden = true
        }
    }
}

// MARK: - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {

    @objc // Потому что по умолчанию его нет
    func nameTextFieldDidChange(_ textField: UITextField) {
        viewModel?.userName.value = textField.text
    }
}

// MARK: - UITextViewDelegate
extension ProfileViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel?.userDescription.value = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        userDescriptionPlaceholderState(.off)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel?.userDescription.value = textView.text
    }
}

// MARK: - Animations
extension ProfileViewController {
    func animateImageViewChange() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
            self?.profileView.profileImageView.transform = CGAffineTransform(
                scaleX: 1.4, y: 1.4
            )
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
                self?.profileView.profileImageView.transform = .identity
            }
        })
    }
}
