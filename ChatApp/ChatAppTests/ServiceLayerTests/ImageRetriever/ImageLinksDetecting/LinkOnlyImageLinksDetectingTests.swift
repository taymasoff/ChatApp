//
//  LinksOnlyImageLinksDetectingTests.swift
//  ChatAppTests
//
//  Created by Тимур Таймасов on 07.12.2021.
//

import XCTest
@testable import ChatApp

/// Тесты первого метода дефолтной реализации ImageLinksDetecting протокола,
/// который возвращает ссылку на картинку, если она есть в тексте или nil - если ее нет
class LinkOnlyImageLinksDetectingTests: XCTestCase {
    
    /// Пустой класс для тестирования дефолтной реализации ImageLinksDetecting протокола
    class TestImageLinksDetecting: ImageLinksDetecting { }
    
    func testWithEmptyText() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = ""
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertNil(resultURL)
    }
    
    func testWithTextContainingNoImageLinks() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "Lorem Ipsum?"
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertNil(resultURL)
    }
    
    func testWithTextThatIsPurelyOneNonImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "vk.com"
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertNil(resultURL)
    }
    
    func testWithTextThatIsPurelyOnePNGImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.png"
        let expectedOutput: URL = URL(string: inputText)!
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(resultURL, expectedOutput)
    }
    
    func testWithTextThatIsPurelyOneJPEGImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.jpeg"
        let expectedOutput: URL = URL(string: inputText)!
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(resultURL, expectedOutput)
    }
    
    func testWithTextThatIsPurelyOneJPGImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.jpg"
        let expectedOutput: URL = URL(string: inputText)!
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(resultURL, expectedOutput)
    }
    
    func testWithTextThatIsPurelyOneGIFImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.gif"
        let expectedOutput: URL = URL(string: inputText)!
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(resultURL, expectedOutput)
    }
    
    func testWithTextContainingOneNonImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "This text has non-image link in it. There it is: edu.tinkoff.ru/my-activities"
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertNil(resultURL)
    }
    
    func testWithTextContainingOneImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let imageLinkInText = "imagelinks.com/imagelink.gif"
        let inputText: String = "This text has image link in it. There it is: \(imageLinkInText)"
        let expectedOutput: URL = URL(string: imageLinkInText)!
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(resultURL, expectedOutput)
    }
    
    func testWithTextContainingMultipleImageLinks() {
        let (sut, promise) = makeSUTAndPromise()
        let imageLinksInText = ["imagelinks.com/imagelink.gif",
                                "differentImageLinks.com/someimage.png",
                                "somesitewithimagelink.com/totallydifferentlink.jpeg"]
        let inputText: String = """
This text has multiple image links in it. There is first one: \(imageLinksInText.first!) Then this one: \(imageLinksInText[1]) And also third one: \(imageLinksInText[2])
"""
        let expectedOutput: URL = URL(string: imageLinksInText.first!)!
        var resultURL: URL?
        
        sut.findFirstImageLink(inText: inputText) { (link: URL?) in
            resultURL = link
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(resultURL, expectedOutput)
    }
    
    // MARK: - Helpers
    func makeSUTAndPromise() -> (TestImageLinksDetecting, XCTestExpectation) {
        return (TestImageLinksDetecting(), XCTestExpectation())
    }
}
