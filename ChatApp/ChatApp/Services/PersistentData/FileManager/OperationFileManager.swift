//
//  OperationFileManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.10.2021.
//

import Foundation

// MARK: - Operation Queue Supportable
protocol FMOperationQueueSupportable {
    init(fileManager: FileManager,
         qos: QualityOfService,
         operationQueue: OperationQueue)
}

/// OperationBased File Manager
class OperationFileManager: AsyncFileManagerProtocol, FMOperationQueueSupportable {
    
    // MARK: - Properties
    var fileManager: FileManager
    private var qos: QualityOfService
    lazy var operationQueue: OperationQueue = OperationQueue()
    
    // MARK: - Init
    init(fileManager: FileManager = FileManager.default,
         qos: QualityOfService = .default) {
        self.fileManager = fileManager
        self.qos = qos
    }
    
    // MARK: - OperationQueueSupportable Init
    required init(fileManager: FileManager = FileManager.default,
                  qos: QualityOfService = .default,
                  operationQueue: OperationQueue = OperationQueue()) {
        self.fileManager = fileManager
        self.qos = qos
        self.operationQueue = operationQueue
    }
    
    // MARK: - Async Read
    func read(fromFileNamed name: String,
              at directory: FMDirectory,
              completion: @escaping ResultHandler<Data>) {
        
        let readOperation = FileReadOperation(fileManager: self,
                                              fileName: name,
                                              directory: directory)
        readOperation.qualityOfService = qos
        operationQueue.addOperation(readOperation)
        readOperation.onResult = { result in
            completion(result)
        }
    }
    
    // MARK: - Async Write
    func write(data: Data, inFileNamed name: String, at directory: FMDirectory, completion: @escaping ResultHandler<Bool>) {
        
        let writeOperation = FileWriteOperation(data: data,
                                                fileName: name,
                                                directory: directory)
        writeOperation.qualityOfService = qos
        operationQueue.addOperation(writeOperation)
        writeOperation.onResult = { result in
            completion(result)
        }
    }
    
    // MARK: - Set Qos
    func setQoS(_ qos: QualityOfService) {
        self.qos = qos
    }
}
