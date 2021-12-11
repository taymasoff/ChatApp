//
//  ProfileView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.09.2021.
//

import UIKit
import SnapKit
import Rswift

/// Popup вью профиля
class ProfileView: UIView {
    
    // MARK: - Properties
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.backgroundColor = .clear
        activity.color = ThemeManager.currentTheme.settings.tintColor
        addSubview(activity)
        activity.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return activity
    }()
    
    private(set) var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private(set) var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Your name",
            attributes: [NSAttributedString.Key
                            .foregroundColor: ThemeManager.currentTheme.settings.subtitleTextColor]
        )
        textField.backgroundColor = .clear
        textField.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        textField.minimumFontSize = 18
        textField.adjustsFontSizeToFitWidth = true
        textField.textColor = ThemeManager.currentTheme.settings.titleTextColor
        textField.textAlignment = .center
        textField.autocorrectionType = .no
        return textField
    }()
    
    private(set) var userDescriptionTextView: UITextView = makeUserDescriptionTextView()
    
    private(set) var userDescriptionTextViewPlaceholder: UITextView = {
        let textView = makeUserDescriptionTextView()
        textView.backgroundColor = .clear
        textView.textColor = ThemeManager.currentTheme.settings.subtitleTextColor
        textView.isUserInteractionEnabled = false
        textView.text = "Tell something about yourself..."
        return textView
    }()
    
    private(set) var userNameUndoButton: UIButton = makeUndoButton()
    
    private(set) var userDescriptionUndoButton: UIButton = makeUndoButton()
    
    private(set) var profileImageUndoButton: UIButton = {
        let button = makeUndoButton()
        button.setTitle("Reset Photo", for: .normal)
        return button
    }()
    
    private(set) var setImageButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let tintedImage = R.image.camera()?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        return button
    }()
    
    private(set) var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.layer.cornerRadius = 10
        let buttonColor = ThemeManager.currentTheme.settings.tintColor
        button.backgroundColor = buttonColor
        let titleColor = UIColor.contrastingColor(to: buttonColor, for: .title)
        button.setTitleColor(titleColor, for: .normal)
        return button
    }()
    
    private(set) var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.currentTheme.settings.secondaryColor
        view.isUserInteractionEnabled = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private var nameContainerView = UIView()
    
    private var descriptionContainerView = UIView()
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.currentTheme.settings.mainColor
        view.layer.cornerRadius = 35
        view.layer.maskedCorners = [.layerMaxXMinYCorner,
                                    .layerMinXMinYCorner]
        return view
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .clear
        setupSubviews()
        
        hideNameUndoButton(animated: false)
        hideDescriptionUndoButton(animated: false)
        hideProfileUndoButton(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        setSubviewsHierarchy()
        setSubviewsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let circleCornerRadius = circleView.frame.size.width / 2
        circleView.layer.cornerRadius = circleCornerRadius
        profileImageView.layer.cornerRadius = circleCornerRadius
        updateSetImageButtonFrame()
    }
}

// MARK: - Show/Hide Undo Buttons
extension ProfileView {
    func hideNameUndoButton(animated: Bool = true) {
        userNameUndoButton.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        if animated {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.userNameUndoButton.alpha = 0.0
                self?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.userNameUndoButton.isHidden = true
            })
        } else {
            userNameUndoButton.alpha = 0.0
            userNameUndoButton.isHidden = true
        }
    }
    
    func showNameUndoButton(animated: Bool = true) {
        userNameUndoButton.snp.updateConstraints { make in
            make.height.equalTo(userNameUndoButton.intrinsicContentSize.height)
        }
        self.userNameUndoButton.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.userNameUndoButton.alpha = 1.0
                self?.layoutIfNeeded()
            })
        } else {
            userNameUndoButton.alpha = 1.0
        }
    }
    
    func hideDescriptionUndoButton(animated: Bool = true) {
        userDescriptionUndoButton.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        if animated {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.userDescriptionUndoButton.alpha = 0.0
                self?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.userDescriptionUndoButton.isHidden = true
            })
        } else {
            userDescriptionUndoButton.alpha = 0.0
            userDescriptionUndoButton.isHidden = true
        }
    }
    
    func showDescriptionUndoButton(animated: Bool = true) {
        userDescriptionUndoButton.snp.updateConstraints { make in
            make.height.equalTo(userDescriptionUndoButton.intrinsicContentSize.height)
        }
        self.userDescriptionUndoButton.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.userDescriptionUndoButton.alpha = 1.0
                self?.layoutIfNeeded()
            })
        } else {
            userDescriptionUndoButton.alpha = 1.0
        }
    }
    
    func hideProfileUndoButton(animated: Bool = true) {
        profileImageUndoButton.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        if animated {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.profileImageUndoButton.alpha = 0.0
                self?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.profileImageUndoButton.isHidden = true
            })
        } else {
            profileImageUndoButton.alpha = 0.0
            profileImageUndoButton.isHidden = true
        }
    }
    
    func showProfileUndoButton(animated: Bool = true) {
        profileImageUndoButton.snp.updateConstraints { make in
            make.height.equalTo(profileImageUndoButton.intrinsicContentSize.height)
        }
        self.profileImageUndoButton.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.profileImageUndoButton.alpha = 1.0
                self?.layoutIfNeeded()
            })
        } else {
            profileImageUndoButton.alpha = 1.0
        }
    }
}

// MARK: - ProfileView Subviews Setup
private extension ProfileView {
    func setSubviewsHierarchy() {
        addSubview(backgroundView)
        addSubview(circleView)
        circleView.addSubview(profileImageView)
        addSubview(setImageButton)
        addSubview(nameContainerView)
        nameContainerView.addSubview(userNameTextField)
        nameContainerView.addSubview(userNameUndoButton)
        addSubview(descriptionContainerView)
        descriptionContainerView.addSubview(userDescriptionTextView)
        descriptionContainerView.addSubview(userDescriptionTextViewPlaceholder)
        descriptionContainerView.addSubview(userDescriptionUndoButton)
        addSubview(profileImageUndoButton)
        addSubview(saveButton)
    }
    
    func setSubviewsLayout() {
        // MARK: ProfileImageView Layout
        circleView.snp.makeConstraints { make in
            make.size.equalTo(self.snp.width).multipliedBy(0.5)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(circleView)
            make.center.equalTo(circleView)
        }
        
        // MARK: BackgroundView Layout
        backgroundView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(circleView.snp.centerY)
        }
        
        // MARK: UserNameTextField Layout
        userNameTextField.snp.makeConstraints { make in
            make.left.right.equalTo(self).inset(10)
            make.top.equalTo(profileImageView.snp.bottom).offset(40)
        }
        
        // MARK: UserNameUndoButton Layout
        userNameUndoButton.snp.makeConstraints { make in
            make.centerX.equalTo(userNameTextField)
            make.top.equalTo(userNameTextField.snp.bottom)
            make.height.equalTo(userNameUndoButton.intrinsicContentSize.height)
        }
        
        // MARK: NameContainerView Layout
        nameContainerView.snp.makeConstraints { make in
            make.left.right.top.equalTo(userNameTextField)
            make.bottom.equalTo(userNameUndoButton)
        }
        
        // MARK: UserDescriptionTextView Layout
        userDescriptionTextView.snp.makeConstraints { make in
            make.left.right.equalTo(self).inset(40)
            make.top.equalTo(nameContainerView.snp.bottom).offset(20)
        }
        
        // MARK: UserDescriptionUndoButton Layout
        userDescriptionUndoButton.snp.makeConstraints { make in
            make.centerX.equalTo(userDescriptionTextView)
            make.top.equalTo(userDescriptionTextView.snp.bottom)
            make.height.equalTo(userDescriptionUndoButton.intrinsicContentSize.height)
        }
        
        // MARK: UserDescriptionUndoButton Layout
        profileImageUndoButton.snp.makeConstraints { make in
            make.centerX.equalTo(profileImageView)
            make.top.equalTo(profileImageView.snp.bottom)
            make.height.equalTo(profileImageUndoButton.intrinsicContentSize.height)
        }
        
        // MARK: DescriptionContainerView Layout
        descriptionContainerView.snp.makeConstraints { make in
            make.left.right.top.equalTo(userDescriptionTextView)
            make.bottom.equalTo(userDescriptionUndoButton)
        }
        
        // MARK: SetImageButton Layout
        setImageButton.imageView?.snp.makeConstraints { make in
            make.edges.equalTo(setImageButton.snp.edges).inset(8)
        }
        
        // MARK: SaveButton Layout
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionContainerView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().inset(60 + safeAreaInsets.bottom)
            make.height.greaterThanOrEqualTo(50)
        }
        
        // MARK: UserDescriptionTextViewPlaceholder Layout
        userDescriptionTextViewPlaceholder.snp.makeConstraints { make in
            make.edges.equalTo(userDescriptionTextView)
        }
    }
    
    private func updateSetImageButtonFrame() {
        // Формула для нахождения точки на окружности
        let radius = circleView.frame.size.width / 2
        let xCoord = radius * sin(45 * (Double.pi / 180))
        let yCoord = radius * cos(45 * (Double.pi / 180))
        
        setImageButton.frame.size = CGSize(width: circleView.frame.size.width / 5,
                                           height: circleView.frame.size.width / 5)
        setImageButton.center = CGPoint(x: circleView.center.x + xCoord,
                                        y: circleView.center.y + yCoord)
        
        setImageButton.layer.cornerRadius = setImageButton.frame.size.width / 2
    }
    
    private static func makeUserDescriptionTextView() -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        textView.textColor = ThemeManager.currentTheme.settings.titleTextColor
        textView.autocorrectionType = .no
        return textView
    }
    
    private static func makeUndoButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Undo Changes", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.backgroundColor = .clear
        button.setTitleColor(ThemeManager.currentTheme.settings.tintColor,
                             for: .normal)
        return button
    }
}
