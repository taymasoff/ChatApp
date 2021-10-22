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
    var profileView: ProfileView!
    
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
        
        setupGestureRecognizers()
        bindWithViewModel()
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
            for: .touchUpInside)
        
        profileView.addGestureRecognizer(UITapGestureRecognizer(
            target: profileView,
            action: #selector(UIView.endEditing(_:))))
        
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(didSwipeProfileViewDown))
        swipeDown.direction = .down
        
        profileView.addGestureRecognizer(swipeDown)
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTapOutsideProfileView)))
    }
    
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
    
    // MARK: - Show/Hide Profile View Animations
    
    fileprivate func showProfileView(animated: Bool) {
        if animated {
            profileView.snp.remakeConstraints { make in
                make.bottom.right.left.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.7)
            }
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
    
    fileprivate func dismissProfileView(animated: Bool) {
        view.endEditing(true) // Убираем клавиатуру если она есть
        if animated {
            profileView.snp.remakeConstraints { make in
                make.right.left.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.7)

                make.top.equalTo(view.snp.bottom)
                    .offset(profileView.profileImageView.frame.height/2)
            }
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) {
                self.view.layoutIfNeeded()
            } completion: { [unowned self] _ in
                self.dismiss(animated: false, completion: nil)
            }
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: - ViewModelBindable
extension ProfileViewController: ViewModelBindable {
    func bindWithViewModel() {
        viewModel?.userName.bind(listener: { [unowned self] name in
            self.profileView.userNameLabel.text = name
        })
        viewModel?.userDescription.bind(listener: { [unowned self] description in
            self.profileView.userDescription.text = description
        })
        viewModel?.userAvatar.bind(listener: { [unowned self] image in
            if let image = image {
                // Удаляем инициалы с ProfileImageView если они там есть
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
    }
}

// MARK: - ProfileViewController Subviews Setup
private extension ProfileViewController {
    func makeProfileView() -> ProfileView {
        let profileView = ProfileView(frame: view.frame)
        self.view.addSubview(profileView)
        
        // Скругляем углы, только верхние
        profileView.layer.cornerRadius = profileView.frame.size.width / 10
        profileView.layer.maskedCorners = [.layerMaxXMinYCorner,
                                            .layerMinXMinYCorner]
        // Создаем констрейнты за пределами экрана для анимации
        profileView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
            make.top.equalTo(view.snp.bottom)
                .offset(profileView.profileImageView.frame.height/2)
        }
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
            
            profileView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-keyboardSize.height)
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
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
