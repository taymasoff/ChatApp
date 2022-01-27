//
//  LinkDetectorProtocol.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 25.11.2021.
//

import Foundation

protocol ImageLinksDetecting {
    
    /// Находит первую попавшуются ссылку и возвращает ее
    func findFirstImageLink(inText text: String,
                            completion: @escaping (_ link: URL?) -> Void)
    
    /// Находит первую попавшуюся ссылку и возвращает текст без нее
    func findFirstImageLink(inText text: String,
                            completion: @escaping ((link: URL, text: String)?) -> Void)
}

extension ImageLinksDetecting {
    
    func findFirstImageLink(inText text: String,
                            completion: @escaping (_ link: URL?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let textArray = text.components(separatedBy: " ")
            for word in textArray {
                if word.isImageLink(), let url = URL(string: word) {
                    completion(url)
                    return
                }
            }
            completion(nil)
        }
    }
    
    func findFirstImageLink(inText text: String,
                            completion: @escaping ((link: URL, text: String)?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            var textArray = text.components(separatedBy: " ")
            var link: URL?
            var indexOfLink: Int?
            for (ind, word) in textArray.enumerated() {
                if word.isImageLink(), let url = URL(string: word) {
                    link = url
                    indexOfLink = ind
                    break
                }
            }
            if let link = link, let indexOfLink = indexOfLink {
                textArray.remove(at: indexOfLink)
                completion((link, textArray.joined(separator: " ")))
            } else {
                completion(nil)
            }
        }
    }
}

private extension String {
    func isImageLink() -> Bool {
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        
        if let ext = self.getExtension() {
            return imageFormats.contains(ext)
        } else {
            return false
        }
    }
    
    func getExtension() -> String? {
        let ext = (self as NSString).pathExtension
        return ext.isEmpty ? nil : ext
    }
}
