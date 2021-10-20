//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import SnapKit

/// Контроллер экрана профиля
final class ProfileViewController: UIViewController, ViewModelBased {
    
    // MARK: - Properties
    lazy var blurredView = BlurredView()
    private var profileView: ProfileView!
    
    var viewModel: ProfileViewModel?
    lazy var nameFormatter = PersonNameComponentsFormatter()
    
    // MARK: - Initializers
    convenience init(with viewModel: ProfileViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        super.loadView()
        profileView = makeProfileView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileView.userNameTextField.delegate = self
        profileView.userDescriptionTextView.delegate = self
        setupGestureRecognizers()
        
        bindWithViewModel()
        viewModel?.loadLastUIStateFromPersistentStorage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.insertSubview(blurredView, at: 0)
        showProfileView(animated: true)
    }

    // MARK: - Private Methods
    // MARK: Gesture Recognizer Setup
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
        
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(didSwipeProfileViewDown)
        )
        swipeDown.direction = .down
        
        profileView.addGestureRecognizer(swipeDown)
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTapOutsideProfileView))
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
    fileprivate func editProfileImagePressed() {
        viewModel?.editProfileImagePressed(sender: self)
    }
    
    @objc
    fileprivate func didTapOutsideProfileView() {
        dismissProfileView(animated: true)
        viewModel?.didDismissProfileView()
    }
    @objc
    fileprivate func didSwipeProfileViewDown() {
        dismissProfileView(animated: true)
        viewModel?.didDismissProfileView()
    }
    
    @objc
    fileprivate func didTapProfileImageUndoButton() {
        viewModel?.userAvatar.restore()
        profileView.hideProfileUndoButton()
    }
    
    @objc
    fileprivate func didTapUserNameUndoButton() {
        viewModel?.userName.restore()
        profileView.hideNameUndoButton()
    }
    
    @objc
    fileprivate func didTapUserDescriptionUndoButton() {
        viewModel?.userDescription.restore()
        profileView.hideDescriptionUndoButton()
    }
    
    @objc
    fileprivate func didTapSaveButton() {
        viewModel?.saveCurrentUIState()
        profileView.hideNameUndoButton()
        profileView.hideDescriptionUndoButton()
        profileView.hideProfileUndoButton()
    }
    
    // MARK: UserDescriptionTextView Placeholder Management
    fileprivate func showUserDescriptionPlaceholder() {
        profileView.userDescriptionTextView.text = "Tell us about yourself..."
        profileView.userDescriptionTextView.textColor = ThemeManager.currentTheme.settings.subtitleTextColor
    }
    
    fileprivate func removeUserDescriptionPlaceholder() {
        profileView.userDescriptionTextView.text = nil
        profileView.userDescriptionTextView.textColor = ThemeManager.currentTheme.settings.titleTextColor
    }
}

// MARK: - ViewModelBindable
extension ProfileViewController: ViewModelBindable {
    func bindWithViewModel() {
        // MARK: Bind userName to userNameTextField
        viewModel?.userName.bind(listener: { [unowned self] name in
            self.profileView.userNameTextField.text = name
            // Обновляем плейсхолдер аватарки с инициалами нашего имени,
            // если userAvatar все еще nil
            if self.viewModel?.userAvatar.value == nil {
                self.profileView.profileImageView.addProfilePlaceholder(fullName: name)
            }
        })
        // MARK: Bind userDescription to userDescriptionTextField
        viewModel?.userDescription.bind(listener: { [unowned self] description in
            if let description = description, description != "" {
                self.removeUserDescriptionPlaceholder()
                self.profileView.userDescriptionTextView.text = description
            } else {
                self.showUserDescriptionPlaceholder()
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
            } else {
                self.profileView.hideNameUndoButton()
            }
        })
        // MARK: Bind userDescription Updates
        viewModel?.userDescription.bindUpdates(updatesListener: { [unowned self] isChanged in
            if isChanged {
                self.profileView.showDescriptionUndoButton()
            } else {
                self.profileView.hideDescriptionUndoButton()
            }
        })
        // MARK: Bind userAvatar Updates
        viewModel?.userAvatar.bindUpdates(updatesListener: { [unowned self] isChanged in
            if isChanged {
                self.profileView.showProfileUndoButton()
            } else {
                self.profileView.hideProfileUndoButton()
            }
        })
        
        viewModel?.isLoading.bind(listener: { [unowned self] isLoading in
            if isLoading {
                self.profileView.activityIndicator.startAnimating()
            } else {
                self.profileView.activityIndicator.stopAnimating()
            }
        })
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
        // Если был Placeholder - убираем его
        if profileView.userDescriptionTextView.textColor ==
            ThemeManager.currentTheme.settings.subtitleTextColor {
            removeUserDescriptionPlaceholder()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel?.userDescription.value = textView.text
        // Если текст пустой - ставим Placeholder
        if textView.text.isEmpty {
            showUserDescriptionPlaceholder()
        }
    }
}

// MARK: - Show/Hide Profile View Animations
private extension ProfileViewController {
    func showProfileView(animated: Bool) {
        profileView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
    
    
    func dismissProfileView(animated: Bool) {
        view.endEditing(true) // Убираем клавиатуру если она есть
        profileView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
                .offset(profileView.profileImageView.frame.height/2)
                .offset(profileView.frame.height)
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) {
                self.view.layoutIfNeeded()
            } completion: { [weak self] _ in
                self?.dismiss(animated: false, completion: nil)
            }
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: - ProfileViewController Subviews Setup
private extension ProfileViewController {
    func makeProfileView() -> ProfileView {
        let profileView = ProfileView(frame: view.frame)
        view.addSubview(profileView)
        
        // Скругляем углы, только верхние
        profileView.layer.cornerRadius = profileView.frame.size.width / 10
        profileView.layer.maskedCorners = [.layerMaxXMinYCorner,
                                            .layerMinXMinYCorner]
        // Создаем констрейнты за пределами экрана для анимации
        profileView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
            make.bottom.equalToSuperview()
                .offset(profileView.profileImageView.frame.height/2)
                .offset(profileView.frame.height)
        }
        view.layoutIfNeeded()
        return profileView
    }
}

// MARK: - KeyboardObservers
/*
 Когда появляется клавиатура - смещаем вьюшку наверх с той же скоростью, с которой появляется клавиатура. Когда клавиатура убирается, делаем то же самое, только наоборот.
 */

private extension ProfileViewController {
    func addKeyboardObserver() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(keyboardWillShow),
                         name: UIResponder.keyboardWillShowNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(keyboardWillHide),
                         name: UIResponder.keyboardWillHideNotification,
                         object: nil)
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            if !profileView.userNameTextField.isEditing {
                profileView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(-keyboardSize.height)
                }
                
                UIView.animate(withDuration: duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            profileView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
