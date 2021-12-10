//
//  DummyCachedImageFetcher.swift
//  ChatAppTests
//
//  Created by Тимур Таймасов on 08.12.2021.
//

import Foundation
@testable import ChatApp

class DummyCachedImageFetcher: CachedImageFetcherProtocol {
    func clearImageCache() {
        assertionFailure("DummyCachedImageFetcher methods should not be called!")
    }
    
    func fetchCachedImage(from url: URL, completion: @escaping ResultHandler<UIImage>) {
        assertionFailure("DummyCachedImageFetcher methods should not be called!")
    }
    
    func fetchCachedImage(from url: String, completion: @escaping ResultHandler<UIImage>) {
        assertionFailure("DummyCachedImageFetcher methods should not be called!")
    }
}
