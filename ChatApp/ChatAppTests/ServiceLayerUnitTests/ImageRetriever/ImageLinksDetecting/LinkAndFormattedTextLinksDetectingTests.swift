//
//  LinkAndFormattedTextLinksDetectingTests.swift
//  ChatAppTests
//
//  Created by Тимур Таймасов on 07.12.2021.
//

import XCTest
@testable import ChatApp

/// Тесты второго метода дефолтной реализации ImageLinksDetecting протокола,
/// который возвращает опциональный тюпл, содержащий ссылку на картинку плюс текст без этой картинки
class LinkAndFormattedTextImageLinksDetectingTests: XCTestCase {
    
    /// Пустой класс для тестирования дефолтной реализации ImageLinksDetecting протокола
    class TestImageLinksDetecting: ImageLinksDetecting { }
    
    typealias OutputType = (link: URL, newText: String)
    
    func testWithEmptyText() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = ""
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertNil(result)
    }
    
    func testWithTextContainingNoImageLinks() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "Lorem Ipsum?"
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 2)
        
        XCTAssertNil(result)
    }
    
    func testWithTextThatIsPurelyOneNonImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "vk.com"
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertNil(result)
    }
    
    func testWithTextThatIsPurelyOnePNGImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.png"
        let expectedOutputURL: URL = URL(string: inputText)!
        let expectedOutputText: String = ""
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertEqual(result?.link, expectedOutputURL)
        XCTAssertEqual(result?.newText, expectedOutputText)
    }
    
    func testWithTextThatIsPurelyOneJPEGImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.jpeg"
        let expectedOutputURL: URL = URL(string: inputText)!
        let expectedOutputText: String = ""
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertEqual(result?.link, expectedOutputURL)
        XCTAssertEqual(result?.newText, expectedOutputText)
    }
    
    func testWithTextThatIsPurelyOneJPGImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.jpg"
        let expectedOutputURL: URL = URL(string: inputText)!
        let expectedOutputText: String = ""
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertEqual(result?.link, expectedOutputURL)
        XCTAssertEqual(result?.newText, expectedOutputText)
    }
    
    func testWithTextThatIsPurelyOneGIFImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "somesite.com/someimage.gif"
        let expectedOutputURL: URL = URL(string: inputText)!
        let expectedOutputText: String = ""
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertEqual(result?.link, expectedOutputURL)
        XCTAssertEqual(result?.newText, expectedOutputText)
    }
    
    func testWithTextContainingOneNonImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let inputText: String = "This text has non-image link in it. There it is: edu.tinkoff.ru/my-activities"
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertNil(result)
    }
    
    func testWithTextContainingOneImageLink() {
        let (sut, promise) = makeSUTAndPromise()
        let imageLinkInText = "imagelinks.com/imagelink.gif"
        let inputTextWithoutLink: String = "This text has image link in it. There it is: "
        let inputTextWithLink: String = "\(inputTextWithoutLink) \(imageLinkInText)"
        let expectedOutputURL: URL = URL(string: imageLinkInText)!
        let expectedOutputText: String = inputTextWithoutLink
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputTextWithLink) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertEqual(result?.link, expectedOutputURL)
        XCTAssertEqual(result?.newText, expectedOutputText)
    }
    
    func testWithTextContainingMultipleImageLinks() {
        let (sut, promise) = makeSUTAndPromise()
        let imageLinksInText = ["imagelinks.com/imagelink.gif",
                                "differentImageLinks.com/someimage.png",
                                "somesitewithimagelink.com/totallydifferentlink.jpeg"]
        let inputText: String = """
This text has multiple image links in it. There is first one: \(imageLinksInText.first!) Then this one: \(imageLinksInText[1]) And also third one: \(imageLinksInText[2])
"""
        let expectedOutputURL: URL = URL(string: imageLinksInText.first!)!
        let expectedOutputText: String = """
This text has multiple image links in it. There is first one: Then this one: \(imageLinksInText[1]) And also third one: \(imageLinksInText[2])
"""
        
        var result: OutputType?
        
        sut.findFirstImageLink(inText: inputText) { (output: OutputType?) in
            result = output
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        
        XCTAssertEqual(result?.link, expectedOutputURL)
        XCTAssertEqual(result?.newText, expectedOutputText)
    }
    
    // MARK: - Helpers
    func makeSUTAndPromise() -> (TestImageLinksDetecting, XCTestExpectation) {
        return (TestImageLinksDetecting(), XCTestExpectation())
    }
}
