//
//  FileWriteOperation.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.10.2021.
//

import Foundation

class FileWriteOperation: AsyncResultOperation<Bool, Error> {
    private let fileManager: AsyncFileManagerProtocol
    private let data: Data
    private let fileName: String
    private let directory: FMDirectory
    
    init(fileManager: AsyncFileManagerProtocol = GCDFileManager(),
         data: Data,
         fileName: String,
         directory: FMDirectory) {
        self.fileManager = fileManager
        self.data = data
        self.fileName = fileName
        self.directory = directory
        super.init()
    }
    
    override func main() {
        if isCancelled { return }
    
        finish(with: Result {
            try fileManager.write(data: data,
                                  inFileNamed: fileName,
                                  at: directory)
        })
    }
}
