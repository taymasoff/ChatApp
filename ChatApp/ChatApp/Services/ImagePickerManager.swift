//
//  ImagePickerManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 30.09.2021.
//

import UIKit

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var picker = UIImagePickerController()
    var alert = UIAlertController(title: "Choose Image",
                                  message: nil,
                                  preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback: ((UIImage) -> Void)?
    
    override init() {
        super.init()
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }

        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }

    func pickImage(_ viewController: UIViewController,
                   _ callback: @escaping ((UIImage) -> Void)) {
        
        pickImageCallback = callback
        self.viewController = viewController
        
        alert.popoverPresentationController?.sourceView = self.viewController?.view

        viewController.present(alert, animated: true, completion: nil)
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
            viewController?.present(alertController, animated: true)
            return
        }
        pickImageCallback?(image)
    }
}
