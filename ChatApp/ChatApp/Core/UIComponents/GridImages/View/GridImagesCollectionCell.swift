//
//  GridImagesCollectionCell.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 20.11.2021.
//

import UIKit
import SnapKit

final class GridImagesCollectionCell: UICollectionViewCell,
                                      ReuseIdentifiable,
                                      Configurable {

    enum PresentationState {
        case presenting(image: UIImage)
        case loading
        case loadingWithPlaceholder(placeholderImage: UIImage)
        case failed(failImage: UIImage?)
    }
    
    // MARK: - Properties
    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.backgroundColor = .clear
        activity.color = ThemeManager.currentTheme.settings.tintColor
        return activity
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var presentationState: PresentationState = .loading {
        didSet {
            handlePresentationStateChange()
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Config
    func configure(with model: PresentationState) {
        self.presentationState = model
    }
    
    private func setup() {
        roundCorners()
        createShadows()
        setupSubviews()
    }
    
    private func roundCorners() {
        self.contentView.layer.cornerRadius = 12.0
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func createShadows() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 3.0
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = false
        self.clipsToBounds = false
    }
    
    private func setupSubviews() {
        addSubview(imageView)
        addSubview(activityIndicator)
        
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Presentation State Methods
    private func handlePresentationStateChange() {
        switch presentationState {
        case .presenting(let image):
            setToPresentingState(image: image)
        case .loading:
            setToLoadingState()
        case .loadingWithPlaceholder(let image):
            setToLoadingState(image: image)
        case .failed(let image):
            setToFailedState(failImage: image)
        }
    }
    
    private func setToPresentingState(image: UIImage, animated: Bool = true) {
        imageView.image = image
        activityIndicator.stopAnimating()
    }
    
    private func setToLoadingState(image: UIImage? = nil) {
        imageView.image = image
        activityIndicator.startAnimating()
    }
    
    private func setToFailedState(failImage: UIImage?) {
        imageView.image = failImage
        activityIndicator.stopAnimating()
    }
}
