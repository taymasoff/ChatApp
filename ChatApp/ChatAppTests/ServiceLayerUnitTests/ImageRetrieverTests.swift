//
//  ImageRetrieverTests.swift
//  ChatAppTests
//
//  Created by Тимур Таймасов on 07.12.2021.
//

import XCTest
@testable import ChatApp

/// Тесты метода retrieveFirstImage(fromText:) класса ImageRetriever,
/// который должен найти и вернуть первую картинку, в случае если есть ссылка на нее в тексте,
/// либо вернуть дефолтные значения в зависимости от OnFailConfiguration, если ссылка найдена, но запрос не удался.
/// Он также должен вернуть текст, без ссылки на картинку, если картинка найдена.
class ImageRetrieverTests: XCTestCase {
    
    typealias RetrieveFirstImageOutput = (image: UIImage?, newText: String?)
    
    func testWithEmptyText() {
        let (sut, promise) = makeSUTAndPromise(nil, nil)
        let inputText: String = ""
        var result: RetrieveFirstImageOutput?
        
        sut.retrieveFirstImage(fromText: inputText) { image, newText in
            result = (image, newText)
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertNil(result?.image)
        XCTAssertNil(result?.newText)
    }
    
    func testWithTextContainingNoImageLinks() {
        let (sut, promise) = makeSUTAndPromise(nil, nil)
        let inputText: String = "Lorem Ipsum?"
        var result: RetrieveFirstImageOutput?
        
        sut.retrieveFirstImage(fromText: inputText) { image, newText in
            result = (image, newText)
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertNil(result?.image)
        XCTAssertNil(result?.newText)
    }
    
    func testWithTextThatIsPurelyOneImageLinkWhereFetchShouldSucceed() {
        let mockCachedImageFetcher = MockCachedImageFetcher(testConfig: .shouldSucceedWithImage(image: testEnv.imageOnSuccess))
        let (sut, promise) = makeSUTAndPromise(nil, mockCachedImageFetcher)
        let inputText: String = "somesite.com/someimage.png"
        let urlExpectedToBeCalled: URL = URL(string: inputText)!
        let expectedTextoutput: String = ""
        var result: RetrieveFirstImageOutput?
        
        sut.retrieveFirstImage(fromText: inputText) { image, newText in
            result = (image, newText)
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertTrue(mockCachedImageFetcher.verifyFetchCachedImageCalled(withURL: urlExpectedToBeCalled))
        XCTAssertEqual(result?.image, testEnv.imageOnSuccess)
        XCTAssertEqual(result?.newText, expectedTextoutput)
    }
    
    func testWithTextThatIsPurelyOneImageLinkWhereFetchShouldFailExpectingFailText() {
        let mockCachedImageFetcher = MockCachedImageFetcher(testConfig: .shouldFailWithError(error: testEnv.fetchError))
        let (sut, promise) = makeSUTAndPromise(.failText, mockCachedImageFetcher)
        let inputText: String = "somesite.com/someimage.png"
        let urlExpectedToBeCalled: URL = URL(string: inputText)!
        let expectedTextoutput: String = "\(inputText) (\(testEnv.failText))"
        var result: RetrieveFirstImageOutput?
        
        sut.retrieveFirstImage(fromText: inputText) { image, newText in
            result = (image, newText)
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertTrue(mockCachedImageFetcher.verifyFetchCachedImageCalled(withURL: urlExpectedToBeCalled))
        XCTAssertNil(result?.image)
        XCTAssertEqual(result?.newText, expectedTextoutput)
    }
    
    func testWithTextThatIsPurelyOneImageLinkWhereFetchShouldFailExpectingFailImage() {
        let mockCachedImageFetcher = MockCachedImageFetcher(testConfig: .shouldFailWithImage(failImage: testEnv.imageOnFail))
        let (sut, promise) = makeSUTAndPromise(.failText, mockCachedImageFetcher)
        let inputText: String = "somesite.com/someimage.png"
        let urlExpectedToBeCalled: URL = URL(string: inputText)!
        let expectedTextoutput: String = ""
        var result: RetrieveFirstImageOutput?
        
        sut.retrieveFirstImage(fromText: inputText) { image, newText in
            result = (image, newText)
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertTrue(mockCachedImageFetcher.verifyFetchCachedImageCalled(withURL: urlExpectedToBeCalled))
        XCTAssertEqual(result?.image, testEnv.imageOnFail)
        XCTAssertEqual(result?.newText, expectedTextoutput)
    }
    
    func testWithTextThatContainsMultipleImageLinksWhereFetchShouldSucceed() {
        let mockCachedImageFetcher = MockCachedImageFetcher(testConfig: .shouldSucceedWithImage(image: testEnv.imageOnSuccess))
        let (sut, promise) = makeSUTAndPromise(nil, mockCachedImageFetcher)
        let imageLinks = ["imagelinks.com/imagelink.gif",
                          "differentImageLinks.com/someimage.png",
                          "somesitewithimagelink.com/totallydifferentlink.jpeg"]
        let inputText: String = """
This is random text for test, that has first link \(imageLinks.first!) and
some other links. Like this one: \(imageLinks[1]) or this one \(imageLinks[2])
"""
        let urlExpectedToBeCalled: URL = URL(string: imageLinks.first!)!
        let expectedTextoutput: String = """
This is random text for test, that has first link and
some other links. Like this one: \(imageLinks[1]) or this one \(imageLinks[2])
"""
        var result: RetrieveFirstImageOutput?
        
        sut.retrieveFirstImage(fromText: inputText) { image, newText in
            result = (image, newText)
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertTrue(mockCachedImageFetcher.verifyFetchCachedImageCalled(withURL: urlExpectedToBeCalled))
        XCTAssertEqual(result?.image, testEnv.imageOnSuccess)
        XCTAssertEqual(result?.newText, expectedTextoutput)
    }
}

// MARK: - Helpers
extension ImageRetrieverTests {
    
    struct TestEnvironment {
        var imageOnSuccess: UIImage {
            return UIImage(named: "Logo")!
        }
        
        var imageOnFail: UIImage {
            return UIImage(named: "failedToLoad")!
        }
        
        var failText: String {
            return "Some static fail message"
        }
        
        struct FakeFetchError: Error { }
        var fetchError: FakeFetchError {
            return FakeFetchError()
        }
    }
    
    var testEnv: TestEnvironment {
        return TestEnvironment()
    }
    
    /// Копия enum ImageRetriever.OnFailConfiguration, без associatedValue параметров, чтобы легче передавать параметры в factory method makeSUTAndPromise
    enum TestOnFailConfiguration {
        case failImage
        case failText
        case failTextWithError
    }
    
    /// Создает объект класса ImageRetriever с тестовой конфигурацией, а также XCTestExpectation
    /// - Parameters:
    ///   - testOnFailConfiguration: конфигурация ImageRetriever'а, в случае получения ошибки при загрузке картинки.
    ///   Является копией ImageRetriever.OnFailConfiguration, без associatedValue, для простоты инициализации.
    ///   Если значение не передано - устанавливает дефолтный конфиг, который не должен влиять на результат теста.
    ///   - mockCachedImageFetcher: testDouble, соответствующий протоколу CachedImageFetcherProtocol.
    ///   Ожидается моковый объект.
    ///   Если значение не передано - создает DummyCachedImageFetcher, методы которого не должны вызываться при тесте.
    /// - Returns: ImageRetriever и XCTestExpectation
    func makeSUTAndPromise(
        _ testOnFailConfiguration: TestOnFailConfiguration?,
        _ mockCachedImageFetcher: CachedImageFetcherProtocol?
    ) -> (ImageRetriever, XCTestExpectation) {
        
        let onFailConfigurationStub = makeOnFailConfigurationStub(
            basedOn: testOnFailConfiguration
        )
        
        return (
            ImageRetriever(
                imageFetcher: mockCachedImageFetcher ?? DummyCachedImageFetcher(),
                onFailConfiguration: onFailConfigurationStub
            ),
            XCTestExpectation()
        )
    }
    
    /// Создает необходимую конфигурацию для мокового объекта ImageRetriver на основании конфигурации тестовой копии.
    /// - Parameter testOnFailConfiguration: объект TestOnFailConfiguration типа.
    /// Если значение не передано -  возвращает дефолтный конфиг, который не должен влиять на результат теста.
    /// - Returns: OnFailConfiguration, которую можно передать в ImageRetriever
    func makeOnFailConfigurationStub(
        basedOn testOnFailConfiguration: TestOnFailConfiguration?
    ) -> ImageRetriever.OnFailConfiguration {
        
        switch testOnFailConfiguration {
        case .failImage:
            return ImageRetriever.OnFailConfiguration
                .failImage(imageToDisplay: testEnv.imageOnFail)
        case .failText:
            return ImageRetriever.OnFailConfiguration
                .failText(textToAppend: testEnv.failText)
        case .failTextWithError:
            return ImageRetriever.OnFailConfiguration
                .failTextWithError(textToAppend: testEnv.failText)
        default:
            return ImageRetriever.OnFailConfiguration
                .failText(textToAppend: "!!! OnFailConfiguration shouldn't matter in this test case")
        }
    }
}
