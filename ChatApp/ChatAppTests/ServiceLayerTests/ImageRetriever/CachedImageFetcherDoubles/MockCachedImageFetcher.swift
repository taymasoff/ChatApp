//
//  MockCachedImageFetcher.swift
//  ChatAppTests
//
//  Created by Тимур Таймасов on 08.12.2021.
//

import UIKit
@testable import ChatApp

class MockCachedImageFetcher: CachedImageFetcherProtocol {
    
    enum TestConfig {
        case shouldFailWithError(error: Error)
        case shouldFailWithImage(failImage: UIImage)
        case shouldSucceedWithImage(image: UIImage)
    }
    
    var clearImageCacheCalled: Int = 0
    var fetchCachedImageCallsWithURL = [URL]()
    var fetchCachedImageCallsWithStringURL = [String]()
    
    let testConfig: TestConfig
    
    init(testConfig: TestConfig) {
        self.testConfig = testConfig
    }
    
    func clearImageCache() {
        clearImageCacheCalled += 1
    }
    
    func fetchCachedImage(from url: URL,
                          completion: @escaping ResultHandler<UIImage>) {
        
        fetchCachedImageCallsWithURL.append(url)
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Double.random(in: 0.01...0.09)
        ) { [weak self] in
            guard let self = self else { assertionFailure("Self is nil"); return }
            switch self.testConfig {
            case .shouldFailWithError(let error):
                completion(.failure(error))
            case .shouldFailWithImage(let failImage):
                completion(.success(failImage))
            case .shouldSucceedWithImage(let image):
                completion(.success(image))
            }
        }
    }
    
    func fetchCachedImage(from url: String,
                          completion: @escaping ResultHandler<UIImage>) {
        
        fetchCachedImageCallsWithStringURL.append(url)
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Double.random(in: 0.01...0.09)
        ) { [weak self] in
            guard let self = self else { assertionFailure("Self is nil"); return }
            switch self.testConfig {
            case .shouldFailWithError(let error):
                completion(.failure(error))
            case .shouldFailWithImage(let failImage):
                completion(.success(failImage))
            case .shouldSucceedWithImage(let image):
                completion(.success(image))
            }
        }
    }
}

// MARK: - Verification Methods
extension MockCachedImageFetcher {
    func verifyClearImageCachedCalled() -> Bool {
        return clearImageCacheCalled > 0
    }
    
    func verifyFetchCachedImageCalledWithSomeURL() -> Bool {
        return fetchCachedImageCallsWithURL.count > 0
    }
    
    func verifyFetchCachedImageCalledWithSomeStringURL() -> Bool {
        return fetchCachedImageCallsWithStringURL.count > 0
    }
    
    func verifyFetchCachedImageCalled(withURL url: URL) -> Bool {
        return fetchCachedImageCallsWithURL.contains(url)
    }
    
    func verifyFetchCachedImageCalled(withStringURL url: String) -> Bool {
        return fetchCachedImageCallsWithStringURL.contains(url)
    }
}
