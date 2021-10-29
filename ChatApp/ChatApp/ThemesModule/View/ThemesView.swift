//
//  ThemesView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 11.10.2021.
//

import UIKit
import SnapKit
import Rswift

/// Popup вью профиля
class ThemesView: UIView {
        
    var themesPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    var previewView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = ThemeManager.currentTheme.settings.backGroundColor
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 16
        return view
    }()
    
    var previewTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = ThemeManager.currentTheme.settings.titleTextColor
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    var previewSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = ThemeManager.currentTheme.settings.subtitleTextColor
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Theme", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = R.color.appYellow()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.defaultLight.settings.mainColor
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(previewView)
        previewView.addSubview(previewTitleLabel)
        previewView.addSubview(previewSubtitleLabel)
        addSubview(themesPickerView)
        addSubview(confirmButton)
        
        previewTitleLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(10)
        }
        
        previewSubtitleLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(10)
            make.top.equalTo(previewTitleLabel.snp.bottom).inset(-5)
        }
        
        previewView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(20)
            make.bottom.equalTo(themesPickerView.snp.top)
        }
        
        themesPickerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().inset(40)
            make.top.equalTo(themesPickerView.snp.bottom)
            make.height.greaterThanOrEqualTo(50)
        }
    }
}
