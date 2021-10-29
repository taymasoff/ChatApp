//
//  InAppNotificationViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 21.10.2021.
//

import Foundation

final class InAppNotificationViewModel {
    enum NotificationType: String {
        case success = "Успех"
        case error = "Ошибка"
    }
    
    var notificationType: Dynamic<NotificationType> = Dynamic(.success)
    var headerText: Dynamic<String?> = Dynamic(nil)
    var bodyText: Dynamic<String?> = Dynamic(nil)
    var buttonOneText: Dynamic<String?> = Dynamic(nil)
    var buttonTwoText: Dynamic<String?> = Dynamic(nil)
    
    init(notificationType: NotificationType,
         headerText: String? = nil,
         bodyText: String? = nil,
         buttonOneText: String? = nil,
         buttonTwoText: String? = nil) {
        self.notificationType.value = notificationType
        self.headerText.value = headerText ?? notificationType.rawValue
        self.bodyText.value = bodyText
        self.buttonOneText.value = buttonOneText
        self.buttonTwoText.value = buttonTwoText
    }
}
