//
//  AsyncFileManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.10.2021.
//

import Foundation

final class GCDFileManager: AsyncFileManagerProtocol {
    
    // MARK: - Properties
    var fileManager: FileManager
    private var qos: DispatchQoS.QoSClass
    
    // MARK: - Init
    init(fileManager: FileManager = FileManager.default,
         qos: DispatchQoS.QoSClass = .default) {
        self.fileManager = fileManager
        self.qos = qos
    }
    
    // MARK: - Read Operation
    func read(fromFileNamed name: String, at directory: FMDirectory, completion: @escaping ResultHandler<Data>) {
        
        DispatchQueue.global(qos: qos).async {
            completion(
                Result {
                    try self.read(fromFileNamed: name,
                                  at: directory)
                }
            )
        }
    }
    
    // MARK: - Write Operation
    func write(data: Data, inFileNamed name: String, at directory: FMDirectory, completion: @escaping ResultHandler<Bool>) {
        
        DispatchQueue.global(qos: qos).async {
            completion(
                Result {
                    try self.write(data: data,
                                   inFileNamed: name,
                                   at: directory)
                }
            )
        }
    }
    
    // MARK: - Set Qos
    func setQoS(_ qos: QualityOfService) {
        switch qos {
        case .userInteractive:
            self.qos = DispatchQoS.QoSClass.userInteractive
        case .userInitiated:
            self.qos = DispatchQoS.QoSClass.userInitiated
        case .utility:
            self.qos = DispatchQoS.QoSClass.utility
        case .background:
            self.qos = DispatchQoS.QoSClass.background
        case .default:
            self.qos = DispatchQoS.QoSClass.default
        @unknown default:
            self.qos = DispatchQoS.QoSClass.unspecified
        }
    }
}
