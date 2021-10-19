//
//  AsyncFileManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.10.2021.
//

import Foundation

class AsyncFileManager: AsyncFileManagerProtocol {
    var fileManager: FileManager
    var asyncHandler: AsyncHandler
    var qos: QualityOfService
    
    init(fileManager: FileManager = FileManager.default,
         asyncHandler: AsyncHandler = .gcd,
         qos: QualityOfService = .default) {
        self.fileManager = fileManager
        self.qos = qos
        self.asyncHandler = asyncHandler
    }
    
    // MARK: - Async Read
    func read(fromFileNamed name: String,
              at directory: FMDirectory,
              completion: @escaping CompletionHandler<Data>) {
        
        switch asyncHandler {
        case .gcd:
            let qos = getQosForGCD()
            let queue = DispatchQueue.global(qos: qos)
            queue.async {
                completion(
                    Result {
                        try self.read(fromFileNamed: name, at: directory)
                    }
                )
            }
        case .operation(let operationQueue):
            let readOperation = FileReadOperation(fileManager: self,
                                                  fileName: name,
                                                  directory: directory)
            operationQueue.addOperation(readOperation)
            operationQueue.qualityOfService = qos
            readOperation.onResult = { result in
                completion(result)
            }
        }
        
    }
    
    // MARK: - Async Write
    func write(data: Data, inFileNamed name: String, at directory: FMDirectory, completion: @escaping CompletionHandler<Bool>) {
        
        switch asyncHandler {
        case .gcd:
            let qos = getQosForGCD()
            let queue = DispatchQueue.global(qos: qos)
            queue.async {
                completion(
                    Result {
                        try self.write(data: data,
                                       inFileNamed: name,
                                       at: directory)
                    }
                )
            }
        case .operation(let operationQueue):
            let writeOperation = FileWriteOperation(data: data,
                                                    fileName: name,
                                                    directory: directory)
            operationQueue.addOperation(writeOperation)
            operationQueue.qualityOfService = qos
            writeOperation.onResult = { result in
                completion(result)
            }
        }
    }
    
    // QoS у DispatchQueue и QoS у Operation разные классы, поэтому такой адаптер
    private func getQosForGCD() -> DispatchQoS.QoSClass {
        switch qos {
        case .userInteractive:
            return .userInteractive
        case .userInitiated:
            return .userInitiated
        case .utility:
            return .utility
        case .background:
            return .background
        case .default:
            return .default
        @unknown default:
            return .unspecified
        }
    }
}
