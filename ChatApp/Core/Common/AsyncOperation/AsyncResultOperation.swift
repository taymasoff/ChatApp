//
//  AsyncResultOperation.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 19.10.2021.
//

import Foundation

class AsyncResultOperation<Success, Failure>: AsyncOperation where Failure: Error {

    private(set) var result: Result<Success, Failure>! {
        didSet {
            onResult?(result)
        }
    }
    
    var onResult: ((_ result: Result<Success, Failure>) -> Void)?
    
    override func finish() {
        guard !isCancelled else { return super.finish() }
        fatalError("Make use of finish(with:) instead to ensure a result")
    }

    func finish(with result: Result<Success, Failure>) {
        self.result = result
        super.finish()
    }

    override func cancel() {
        fatalError("Make use of cancel(with:) instead to ensure a result")
    }

    func cancel(with error: Failure) {
        self.result = .failure(error)
        super.cancel()
    }
}
