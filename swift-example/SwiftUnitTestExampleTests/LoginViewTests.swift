//
//  LoginViewTests.swift
//  SwiftUnitTestExampleTests
//
//  Created by Drew Hosford on 5/23/25.
//

import XCTest
import SwiftUI
import UIKit
@testable import SwiftUnitTestExample

extension UIView {
    func findViewWithIdentifier(_ identifier: String) -> UIView? {
        if self.accessibilityIdentifier == identifier {
            return self
        }
        
        for subview in self.subviews {
            if let matchingView = subview.findViewWithIdentifier(identifier) {
                return matchingView
            }
        }
        
        return nil
    }
}

final class LoginViewTests: XCTestCase {
    var loginView: LoginView!
    var mockSession: MockURLSession!
    
    override func setUpWithError() throws {
        loginView = LoginView()
        mockSession = MockURLSession()
    }
    
    override func tearDownWithError() throws {
        loginView = nil
        mockSession = nil
    }
    
    func test_GivenTheLoginViewHasLoaded_ThenUsernameAndPasswordTextfieldsAndALoginButtonShallBeDisplayedAndNoErrorsShallBeDisplayed() throws {
        // Arrange
        let view = LoginView()
        
        // Create a hosting controller and properly load the view
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        
        // Wait for the next run loop to ensure view is loaded
        let expectation = XCTestExpectation(description: "View loading")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        // Force layout cycle
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // Find UI components by accessibility identifiers
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        let errorLabel = hostingController.view.findViewWithIdentifier("errorLabel") as? UILabel
        
        // Assert components exist
        XCTAssertNotNil(usernameField, "Username text field should exist")
        XCTAssertNotNil(passwordField, "Password text field should exist")
        XCTAssertNotNil(loginButton, "Login button should exist")
        XCTAssertNotNil(errorLabel, "Error label should exist")
        XCTAssertEqual(errorLabel?.text, "", "Error label should be empty initially")
            }
    
    func testREQ001_ValidCredentialsLogin() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "Login completion")
        let testUsername = "testuser"
        let testPassword = "password123"
        
        mockSession.mockResponse = (
            data: "{}".data(using: .utf8)!,
            response: HTTPURLResponse(
                url: URL(string: "https://testing.com/login")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil)!,
            error: nil
        )
        
        // Act
        loginView.username = testUsername
        loginView.password = testPassword
        
        // Assert
        await loginView.login()
        XCTAssertEqual(loginView.alertMessage, "Login successful")
        XCTAssertTrue(loginView.showAlert)
    }
    
    /// REQ-002: Test failed login with invalid credentials
    /// Test Steps:
    /// 1. Set up mock network response for failed authentication
    /// 2. Enter invalid username and password
    /// 3. Trigger login action
    /// Expected Result: Alert shows failure message
    func testREQ002_InvalidCredentialsLogin() async throws {
        // Arrange
        let testUsername = "wronguser"
        let testPassword = "wrongpass"
        
        mockSession.mockResponse = (
            data: "{}".data(using: .utf8)!,
            response: HTTPURLResponse(
                url: URL(string: "https://testing.com/login")!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil)!,
            error: nil
        )
        
        // Act
        loginView.username = testUsername
        loginView.password = testPassword
        
        // Assert
        await loginView.login()
        XCTAssertEqual(loginView.alertMessage, "Login failed: Status 401")
        XCTAssertTrue(loginView.showAlert)
    }
    
    /// REQ-003: Test login with network error
    /// Test Steps:
    /// 1. Set up mock network to simulate connection error
    /// 2. Enter any credentials
    /// 3. Trigger login action
    /// Expected Result: Alert shows network error message
    func testREQ003_NetworkError() async throws {
        // Arrange
        let testUsername = "testuser"
        let testPassword = "password123"
        
        let testError = NSError(domain: "NetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "Network connection lost"])
        mockSession.mockResponse = (
            data: nil,
            response: nil,
            error: testError
        )
        
        // Act
        loginView.username = testUsername
        loginView.password = testPassword
        
        // Assert
        await loginView.login()
        XCTAssertEqual(loginView.alertMessage, "Error: Network connection lost")
        XCTAssertTrue(loginView.showAlert)
    }
}

// Mock URLSession for testing network calls
class MockURLSession: URLSessionProtocol {
    var mockResponse: (data: Data?, response: URLResponse?, error: Error?)?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let mockTask = MockURLSessionDataTask {
            completionHandler(self.mockResponse?.data, self.mockResponse?.response, self.mockResponse?.error)
        }
        return mockTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}
