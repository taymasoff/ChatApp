//
//  ProfileViewUITests.swift
//  ChatAppUITests
//
//  Created by Тимур Таймасов on 10.12.2021.
//

import XCTest

class ProfileViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testProfileSceneHasAtLeastTwoTextInputFields() {
        let expectedTextInputFieldsInProfileView = 2
        
        app.buttons["profileBarButton"].tap()
        let profileView = app.otherElements["profileView"]
        guard profileView.waitForExistence(timeout: 3) else {
            XCTFail("ProfileView didn't appear in 3 seconds after ProfileBarButton tap")
            return
        }
        let textInputFieldsInProfileView = profileView.textFields.count + profileView.textViews.count
        
        XCTAssertGreaterThanOrEqual(
            textInputFieldsInProfileView,
            expectedTextInputFieldsInProfileView,
            "ProfileView Scene should have at least 2 input fields (textFields/textViews)"
        )
    }
}
