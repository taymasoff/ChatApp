//
//  DMViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation

protocol DMViewModelProtocol {
    var router: RouterProtocol { get }
    init(router: RouterProtocol)
}

final class DMViewModel: DMViewModelProtocol {
    
    var router: RouterProtocol
    
    init(router: RouterProtocol) {
        self.router = router
    }
}
