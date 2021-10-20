//
//  AsyncFileManagerProtocols.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 19.10.2021.
//

import Foundation

// MARK: - Async File Manager Protocol
typealias AsyncFileManagerProtocol = AsyncFMBase & FileManagerProtocol & FMAsyncReadable & FMAsyncWritable

// MARK: - Async Handlers
enum AsyncHandler {
    case gcd
    case operation(OperationQueue? = nil)
}

// MARK: - Async File Manager Base
protocol AsyncFMBase: FMBase {
    var qos: QualityOfService { get }
    var asyncHandler: AsyncHandler { get }
}

// MARK: - Handler
typealias CompletionHandler<T> = (Result<T, Error>) -> Void

// MARK: - File Manager Async Readable
protocol FMAsyncReadable: AsyncFMBase {
    func read(fromFileNamed name: String,
              at directory: FMDirectory,
              completion: @escaping CompletionHandler<Data>)
}

protocol FMAsyncWritable: AsyncFMBase {
    func write(data: Data,
               inFileNamed name: String,
               at directory: FMDirectory,
               completion: @escaping CompletionHandler<Bool>)
}
