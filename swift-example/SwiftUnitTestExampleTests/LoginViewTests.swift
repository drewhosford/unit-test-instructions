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
    
    func test_GivenValidCredentialsAreProvided_WhenTheLoginButtonIsTapped_ThenTheHomeScreenShallDisplay() throws {
        // S1: Navigate to the login screen
        let view = LoginView()
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // S2: Enter valid username and password
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        usernameField?.text = "valid@email.com"
        passwordField?.text = "ValidPass123!"

        // S3: Tap the login button
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        loginButton?.sendActions(for: .touchUpInside)

        // V1: Verify that the home screen is displayed
        let expectation = XCTestExpectation(description: "Home screen appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let homeScreen = hostingController.view.findViewWithIdentifier("homeScreen")
            XCTAssertNotNil(homeScreen, "Home screen should be displayed")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func test_GivenAnInvalidEmailIsProvided_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatTheEmailIsInvalid() throws {
        // S1: Navigate to the login screen
        let view = LoginView()
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // S2: Enter invalid email and valid password
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        usernameField?.text = "invalidemail"
        passwordField?.text = "ValidPass123!"

        // S3: Tap the login button
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        loginButton?.sendActions(for: .touchUpInside)

        // V1: Verify that an error message about invalid email is displayed
        let expectation = XCTestExpectation(description: "Error message appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let errorLabel = hostingController.view.findViewWithIdentifier("errorLabel") as? UILabel
            XCTAssertNotNil(errorLabel, "Error label should exist")
            XCTAssertEqual(errorLabel?.text, "Please enter a valid email address", "Error message should indicate invalid email")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_GivenAPasswordThatDoesNotHaveACaptialLetter_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveACaptialLetter() throws {
        // S1: Navigate to the login screen
        let view = LoginView()
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // S2: Enter valid email and password without capital letter
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        usernameField?.text = "valid@email.com"
        passwordField?.text = "lowercase123!"

        // S3: Tap the login button
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        loginButton?.sendActions(for: .touchUpInside)

        // V1: Verify that an error message about missing capital letter is displayed
        let expectation = XCTestExpectation(description: "Error message appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let errorLabel = hostingController.view.findViewWithIdentifier("errorLabel") as? UILabel
            XCTAssertNotNil(errorLabel, "Error label should exist")
            XCTAssertEqual(errorLabel?.text, "Password must contain at least one capital letter", "Error message should indicate missing capital letter")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_GivenAPasswordIsShorterThan8Characters_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveAtLeast8Characters() throws {
        // S1: Navigate to the login screen
        let view = LoginView()
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // S2: Enter valid email and short password
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        usernameField?.text = "valid@email.com"
        passwordField?.text = "Ab1!"  // Only 4 characters

        // S3: Tap the login button
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        loginButton?.sendActions(for: .touchUpInside)

        // V1: Verify that an error message about password length is displayed
        let expectation = XCTestExpectation(description: "Error message appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let errorLabel = hostingController.view.findViewWithIdentifier("errorLabel") as? UILabel
            XCTAssertNotNil(errorLabel, "Error label should exist")
            XCTAssertEqual(errorLabel?.text, "Password must be at least 8 characters long", "Error message should indicate password length requirement")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsUrlError1009_ThenItShallDisplayAnErrorCommunicatingThatTheDeviceAppearsToBeOffline() throws {
        // S1: Navigate to the login screen
        let view = LoginView()
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // S2: Set up mock network error
        mockSession.mockResponse = (
            data: nil,
            response: nil,
            error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        )

        // S3: Enter valid credentials
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        usernameField?.text = "valid@email.com"
        passwordField?.text = "ValidPass123!"

        // S4: Tap the login button
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        loginButton?.sendActions(for: .touchUpInside)

        // V1: Verify that an error message about offline status is displayed
        let expectation = XCTestExpectation(description: "Error message appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let errorLabel = hostingController.view.findViewWithIdentifier("errorLabel") as? UILabel
            XCTAssertNotNil(errorLabel, "Error label should exist")
            XCTAssertEqual(errorLabel?.text, "Device appears to be offline. Please check your internet connection.", "Error message should indicate offline status")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsUrlError1001_ThenItShallDisplayAnErrorCommunicatingThatTheConnectionAppearsToBeSlowAndTheUserShouldTryAgain() throws {
        // S1: Navigate to the login screen
        let view = LoginView()
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // S2: Set up mock network error
        mockSession.mockResponse = (
            data: nil,
            response: nil,
            error: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        )

        // S3: Enter valid credentials
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        usernameField?.text = "valid@email.com"
        passwordField?.text = "ValidPass123!"

        // S4: Tap the login button
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        loginButton?.sendActions(for: .touchUpInside)

        // V1: Verify that an error message about slow connection is displayed
        let expectation = XCTestExpectation(description: "Error message appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let errorLabel = hostingController.view.findViewWithIdentifier("errorLabel") as? UILabel
            XCTAssertNotNil(errorLabel, "Error label should exist")
            XCTAssertEqual(errorLabel?.text, "Connection appears to be slow. Please try again.", "Error message should indicate slow connection")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsAnyOtherError_ThenItShallDisplayTheStandardDescriptionOfThatError() throws {
        // S1: Navigate to the login screen
        let view = LoginView()
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // S2: Set up mock network error with a generic error
        let genericError = NSError(domain: "com.example.error", code: 999, userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred"])
        mockSession.mockResponse = (
            data: nil,
            response: nil,
            error: genericError
        )

        // S3: Enter valid credentials
        let usernameField = hostingController.view.findViewWithIdentifier("usernameTextField") as? UITextField
        let passwordField = hostingController.view.findViewWithIdentifier("passwordTextField") as? UITextField
        usernameField?.text = "valid@email.com"
        passwordField?.text = "ValidPass123!"

        // S4: Tap the login button
        let loginButton = hostingController.view.findViewWithIdentifier("loginButton") as? UIButton
        loginButton?.sendActions(for: .touchUpInside)

        // V1: Verify that the standard error description is displayed
        let expectation = XCTestExpectation(description: "Error message appears")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let errorLabel = hostingController.view.findViewWithIdentifier("errorLabel") as? UILabel
            XCTAssertNotNil(errorLabel, "Error label should exist")
            XCTAssertEqual(errorLabel?.text, "An unexpected error occurred", "Error message should display the standard error description")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
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
