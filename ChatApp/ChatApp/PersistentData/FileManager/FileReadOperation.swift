//
//  FileReadOperation.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.10.2021.
//

import Foundation

class FileReadOperation: AsyncResultOperation<Data, Error> {
    private let fileManager: AsyncFileManagerProtocol
    private let fileName: String
    private let directory: FMDirectory
    
    init(fileManager: AsyncFileManagerProtocol = AsyncFileManager(),
         fileName: String,
         directory: FMDirectory) {
        self.fileManager = fileManager
        self.fileName = fileName
        self.directory = directory
        super.init()
    }
    
    override func main() {
        if isCancelled { return }
        finish(with: Result {
            try fileManager.read(fromFileNamed: fileName, at: directory)
        })
    }
}
