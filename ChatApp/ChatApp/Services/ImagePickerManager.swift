//
//  ImagePickerManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 30.09.2021.
//

import UIKit

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    typealias PickImageCallback = (_ image: UIImage, _ url: String?) -> Void
    
    private var picker = UIImagePickerController()
    private let alert: UIAlertController = {
        let alert = UIAlertController(title: "Choose Image Source",
                                          message: nil,
                                          preferredStyle: .actionSheet)
        alert.view.tintColor = .systemBlue
        return alert
    }()
    private var viewController: UIViewController?
    private var gridImagesController: GridImagesCollectionViewController?
    var pickImageCallback: PickImageCallback?
    
    override init() {
        super.init()
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }

    func pickImage(_ viewController: UIViewController,
                   _ callback: @escaping PickImageCallback) {
        
        pickImageCallback = callback
        self.viewController = viewController
        
        alert.popoverPresentationController?.sourceView = self.viewController?.view
        
        viewController.present(alert, animated: true)
    }
    
    func openCamera() {
        alert.dismiss(animated: true, completion: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            self.viewController?.present(picker, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Ошибка",
                                                    message: "Камера не обнаружена!",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery() {
        alert.dismiss(animated: true, completion: nil)
        
        picker.sourceType = .photoLibrary
        self.viewController?.present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            let alertController = UIAlertController(title: "Ошибка",
                                                    message: "Не получилось получить изображение",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            viewController?.present(alertController, animated: true)
            return
        }
        pickImageCallback?(image, nil)
    }
}

// MARK: - Extending to support GridImagesViewController
extension ImagePickerManager {
    
    convenience init(gridImagesController: GridImagesCollectionViewController) {
        self.init()
        self.gridImagesController = gridImagesController
        gridImagesController.viewModel?.delegate = self
        self.addGridImagesAction()
    }
    
    private func addGridImagesAction() {
        let gridImagesAction = UIAlertAction(title: "Find online", style: .default) { _ in
            self.openGridImagesPicker()
        }
        alert.addAction(gridImagesAction)
    }
    
    func openGridImagesPicker() {
        alert.dismiss(animated: true, completion: nil)
        guard let gridImagesController = gridImagesController else { return }
        gridImagesController.modalPresentationStyle = .overCurrentContext
        viewController?.present(gridImagesController, animated: false)
    }
}

// MARK: - GridImagesCollectionDelegate
extension ImagePickerManager: GridImagesCollectionDelegate {
    func didPickImage(image: UIImage, url: String) {
        pickImageCallback?(image, url)
    }
}
