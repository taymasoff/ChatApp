//
//  FileManagerProtocols.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.10.2021.
//

import Foundation

// MARK: - File Manager Protocol
typealias FileManagerProtocol = FMBase & FMReadable & FMWritable & FMPathRecievable & FMFileStatusCheckable & FMListable & FMDeletable

// MARK: - File Manager Directories in Documents
enum FMDirectory: String {
    case userProfile = "User Profile Data"
    case themes = "App Themes"
}

// MARK: - File Manager Errors
enum FMError: Error {
    case fileNotFound
    case cantWrite(String)
    case cantCreateFolders(String)
    case cantDeleteFile
    case unexpected(String)
}

// MARK: - File Manager Base
protocol FMBase {
    var fileManager: FileManager { get }
    func createFolders(in url: URL) throws
}

extension FMBase {
    func createFolders(in url: URL) throws {
        let folderUrl = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: folderUrl.path) {
            do {
                try fileManager.createDirectory(at: folderUrl,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                throw FMError.cantCreateFolders(
                    "Can't create folders at path \(folderUrl.path)"
                )
            }
        }
    }
}

protocol FMDeletable {
    func deleteFile(_ fileName: String, at directory: FMDirectory) throws
}

extension FMDeletable where Self: FMPathRecievable {
    func deleteFile(_ fileName: String, at directory: FMDirectory) throws {
        let fullPath = getPath(forFileName: fileName, inDirectory: directory)
        do {
            if fileManager.fileExists(atPath: fullPath.path) {
                try fileManager.removeItem(atPath: fullPath.path)
            } else {
                throw FMError.fileNotFound
            }
        } catch {
            throw FMError.cantDeleteFile
        }
    }
}

// MARK: - File Manager Readable
protocol FMReadable {
    func read(fromFileNamed name: String, at directory: FMDirectory) throws -> Data
}

extension FMReadable where Self: FMPathRecievable {
    func read(fromFileNamed name: String, at directory: FMDirectory) throws -> Data {
        let path = getPath(forFileName: name, inDirectory: directory)
        guard let data = fileManager.contents(atPath: path.path) else {
            throw FMError.fileNotFound
        }
        return data
    }
}

// MARK: - File Manager Writable
protocol FMWritable {
    func write(data: Data,
               inFileNamed name: String,
               at directory: FMDirectory) throws -> Bool
}

extension FMWritable where Self: FMPathRecievable & FMFileStatusCheckable {
    func write(data: Data,
               inFileNamed name: String,
               at directory: FMDirectory) throws -> Bool {
        let path = getPath(forFileName: name, inDirectory: directory)
        
        do {
            do {
                try self.createFolders(in: path)
            } catch {
                throw error
            }
            
            try data.write(to: path, options: .atomic)
            return true
        } catch {
            if isWritable(fileNamed: name, inDirectory: directory) {
                throw FMError.cantWrite(error.localizedDescription)
            } else {
                throw FMError.cantWrite("Файл закрыт для записи")
            }
        }
    }
}

// MARK: - File Manager Path Recievable
protocol FMPathRecievable: FMBase {
    func getAppDocumentsPath() -> URL
    func getDirectoryPath(for directory: FMDirectory) -> URL
    func getPath(forFileName name: String, inDirectory directory: FMDirectory) -> URL
}

extension FMPathRecievable {
    func getAppDocumentsPath() -> URL {
        return fileManager.urls(
            for: .documentDirectory,
               in: .userDomainMask
        ).first!
    }
    
    func getDirectoryPath(for directory: FMDirectory) -> URL {
        return getAppDocumentsPath().appendingPathComponent(directory.rawValue)
    }
    
    func getPath(forFileName name: String, inDirectory directory: FMDirectory) -> URL {
        return getDirectoryPath(for: directory).appendingPathComponent(name)
    }
}

// MARK: - File Manager Status Checkable
protocol FMFileStatusCheckable: FMBase {
    func isReadable(fileNamed name: String, inDirectory directory: FMDirectory) -> Bool
    func isWritable(fileNamed name: String, inDirectory directory: FMDirectory) -> Bool
    func fileExists(fileNamed name: String, inDirectory directory: FMDirectory) -> Bool
}

extension FMFileStatusCheckable where Self: FMPathRecievable {
    func isReadable(fileNamed name: String, inDirectory directory: FMDirectory) -> Bool {
        let path = getPath(forFileName: name, inDirectory: directory)
        return fileManager.isReadableFile(atPath: path.path) ? true : false
    }
    func isWritable(fileNamed name: String, inDirectory directory: FMDirectory) -> Bool {
        let path = getPath(forFileName: name, inDirectory: directory)
        return fileManager.isWritableFile(atPath: path.path) ? true : false
    }
    
    func fileExists(fileNamed name: String, inDirectory directory: FMDirectory) -> Bool {
        let path = getPath(forFileName: name, inDirectory: directory)
        return fileManager.fileExists(atPath: path.path) ? true : false
    }
}

// MARK: - File Manager Listable
protocol FMListable {
    @discardableResult
    func list(filesIn directory: FMDirectory) -> Bool
}

extension FMListable where Self: FMPathRecievable{
    @discardableResult
    func list(filesIn directory: FMDirectory) -> Bool {
        let path = getDirectoryPath(for: directory)
        guard let files = try? fileManager.contentsOfDirectory(
            at: path,
            includingPropertiesForKeys: nil
        ) else {
            print("||| FileManager: Не удалось получить список файлов по пути: |||")
            print("||| \(path) |||")
            return false
        }
        
        if files.count > 0 {
            print("||| FileManager: |||\n")
            for file in files {
                print("||| File: \(file.debugDescription) |||")
            }
            return true
        } else {
            print("||| FileManager: 0 файлов в папке по запросу |||")
            return false
        }
    }
}
