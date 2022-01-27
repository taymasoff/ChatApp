//
//  ConfigurationReaderTests.swift
//  ChatAppTests
//
//  Created by Тимур Таймасов on 12.12.2021.
//

import XCTest
@testable import ChatApp

class ConfigurationReaderTests: XCTestCase {

    func testReadingExistingParameter() {
        let configurationReader = ConfigurationReader.shared
        
        func readingExistingKey() throws {
            let _: String = try configurationReader.readValue(
                inside: .applicationGroup,
                byKey: "defaultUserName"
            )
        }
        
        XCTAssertNoThrow(try readingExistingKey())
    }
    
    func testReadingNonExistingParameter() {
        let configurationReader = ConfigurationReader.shared
        
        func readingNonExistingKey() throws {
            let _: String = try configurationReader.readValue(
                inside: .applicationGroup,
                byKey: "thisKeyDoesNotExist"
            )
        }
        
        XCTAssertThrowsError(try readingNonExistingKey())
    }
}
