//
//  String+containsLetters.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 26.10.2021.
//

import Foundation

/*
 👉 Простая функция, для проверки наличия букв в тексте,
    чтобы не отправлять пустые строки на бек
 */

extension String {
    
    // MARK: Contains Letters
    var containsLetters: Bool {
        if self.rangeOfCharacter(from: NSCharacterSet.letters) != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: IsntEmptyOrWhitespaced
    var isntEmptyOrWhitespaced: Bool {
        guard !self.isEmpty else { return false }
        return (self.trimmingCharacters(in: .whitespaces) != "")
    }
}
