//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import XCTest
import WebKit
@testable import JavaScriptKit

/**
 * Tests executing JavaScript expressions inside a web view.
 *
 * ## Usage
 * To execute tests:
 *
 * ~~~swift
 * testInWebView {
 *     webView in
 *     // Run your tests in this block.
 * }
 * ~~~
 *
 * You can also use expectations in `testInWebView`:
 *
 * ~~~swift
 * let callbackExpectation = expectation(description: "...")
 *
 * testInWebView(expectations: [callbackExpectation] {
 *     webView in
 *     callbackExpectation.fullfill()
 * }
 * ~~~
 *
 * The default timeout is 10s.
 **/

class ExecutionTests: XCTestCase {

    /// The web view where to execute the tests.
    var webView: WKWebView!

    /// Les URLs vers les ressources nécéssaires à l'éxécution des tests.
    let resources: (supportBundle: URL, html: URL) = {
        let supportBundleURL = Bundle(for: ExecutionTests.self)
            .url(forResource: "UnitTestsSupport", withExtension: "bundle")!
        let htmlURL = supportBundleURL.appendingPathComponent("Tests.html", isDirectory: false)
        return (supportBundleURL, htmlURL)
    }()

    /// The pending action queue. Managaed by the test case, do not manipulate.
    var actionQueue = [(WKWebView) -> Void]()

    // MARK: - Lifecycle

    override func setUp() {
        webView = WKWebView()
        webView.navigationDelegate = self
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
        actionQueue.removeAll()
    }

    // MARK: - Test Expected Results

    /// Tests getting a property.
    func testProperty() {
        let property = JSVariable<String>("tester.title")
        checkEvaluationResult(property, expectedValue: "JavaScriptKit Tests")
    }

    /// Tests executing a function that returns a value of the expected type.
    func testSuccessReturnValue() {
        let method = JSFunction<Bool>("tester.refresh")
        checkEvaluationResult(method, expectedValue: true)
    }

    /// Tests executing a function that returns Void.
    func testVoidSuccessValue() {
        let method = JSFunction<JSVoid>("tester.clearQueue")
        checkEvaluationResult(method, expectedValue: JSVoid())
    }

    /// Tests that an error is thrown when the function does not exist.
    func testExpectedError() {
        let method = JSFunction<JSVoid>("yolo.refresh")
        checkEvaluationResult(method, expectedFailure: .executionError(NSError(domain: "", code: 1, userInfo: nil)))
    }

    // MARK: - Test Invalid Value Handling

    /// Tests that an error is thrown when an argument cannot be encoded.
    func testHandleExpressionGenerationError() {
        let value = NotSoEncodable(name: "Error")
        let method = JSFunction<JSVoid>("tester.refresh", arguments: [value])
        checkEvaluationResult(method, expectedFailure: .invalidExpression(NSError(domain: "", code: 1, userInfo: nil)))
    }

    /// Tests that an error is thrown when a value is returned and Void is expected.
    func testHandleUnexpectedReturnValue() {
        let method = JSFunction<JSVoid>("tester.refresh")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: true))
    }

    /// Tests that an error is thrown when the type is mismatching.
    func testInvalidReturnValue() {
        let method = JSFunction<String>("tester.refresh")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: true))
    }

    /// Tests that an error is thrown when the function does not return a value.
    func testMissingReturnValue() {
        let method = JSFunction<Bool>("tester.clearQueue")
        checkEvaluationResult(method, expectedFailure: .unexpectedResult)
    }

    // MARK: - Test JS to Native decoding

    // MARK: Primitives

    /// Tests decoding a String.
    func testDecodeString() {
        let method = JSFunction<String>("tester.testString")
        checkEvaluationResult(method, expectedValue: "Hello, world!")
    }

    /// Tests decoding a number.
    func testDecodeNumber() {
        let method = JSFunction<Int8>("tester.testNumber")
        checkEvaluationResult(method, expectedValue: 42)
    }

    /// Tests decoding a Bool.
    func testDecodeBool() {
        let method = JSFunction<Bool>("tester.testBool")
        checkEvaluationResult(method, expectedValue: true)
    }

    /// Tests decoding a Date.
    func testDecodeDate() {
        let method = JSFunction<Date>("tester.testDate")
        checkEvaluationResult(method, expectedValue: Date(timeIntervalSince1970: 1500))
    }

    // MARK: RawRepresentable

    /// Tests decoding a RawRepresentable.
    func testDecodeValidRawRepresentable() {
        let method = JSFunction<MockTargetType>("tester.testValidMockTargetType")
        checkEvaluationResult(method, expectedValue: .app)
    }

    /// Tests decoding an invalid RawRepresentable.
    func testDecodeInvalidRawRepresentable() {
        let method = JSFunction<MockTargetType>("tester.invalidTestMockTargetRawType")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: 100))
    }

    // MARK: Objects

    /// Tests decoding an object.
    func testDecodeObject() {
        let method = JSFunction<MockTarget>("tester.testTarget")
        let expectedTarget = MockTarget(name: "Client", targetType: .app, categories: ["News", "Entertainment"])
        checkEvaluationResult(method, expectedValue: expectedTarget)
    }

    /// Tests failure when an object is expected but a primitive is returned.
    func testDecodeInvalidObject() {
        let method = JSFunction<MockTarget>("tester.invalidTestTarget")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: false))
    }

    /// Tests decoding failure.
    func testDecodeInvalidObjectPrototype() {
        let method = JSFunction<MockTarget>("tester.invalidTestTargetPrototype")
        let expectedFailingPayload: [AnyHashable : Any] = [
            "name": "Client",
            "targetType": "app",
            "categories": NSNull()
        ]

        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: expectedFailingPayload))
    }

    // MARK: Array of Primitives

    /// Tests decoding an array of primitives.
    func testDecodeArrayOfPrimitives() {
        let method = JSFunction<[UInt16]>("tester.testPrimitivesArray")
        checkEvaluationResult(method, expectedValue: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }

    /// Tests decoding and invalid array of primitives.
    func testDecodeInvalidArrayOfPrimitives() {
        let method = JSFunction<[UInt16]>("tester.testInvalidPrimitivesArray")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: "trolld"))
    }

    /// Tests decoding an array of invalid primitives (mixed types).
    func testDecodeInvalidMixedArrayOfPrimitives() {
        let method = JSFunction<[String]>("tester.testInvalidMixedPrimitivesArray")
        let expectedFailingArray: [Any] = [1, "un", 2, "deux", 3, "trois"]
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: expectedFailingArray))
    }

    // MARK: Array of RawRepresentable

    /// Tests decoding an array of Raw Representables.
    func testDecodeArrayOfRawRepresentable() {
        let method = JSFunction<[MockTargetType]>("tester.testMockTargetTypes")
        checkEvaluationResult(method, expectedValue: [.app, .executable])
    }

    /// Tests decoding an array of invalid raw representable values.
    func testDecodeInvalidArrayOfRawRepresentable() {
        let method = JSFunction<[MockTargetType]>("tester.testInvalidMockTargetTypes")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: false))
    }

    /// Tests decoding an array that doesnt match the expected raw type.
    func testDecodeInvalidRawTypesArray() {
        let method = JSFunction<[MockTargetType]>("tester.testInvalidRawMockTargetTypes")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: [1, 2, 3]))
    }

    /// Tests decoding an unknown raw value.
    func testDecodeUnknownRawValue() {
        let method = JSFunction<[MockTargetType]>("tester.testUnknownRawMockTargetTypes")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: ["app", "kext"]))
    }

    // MARK: Array of Object

    /// Tests decoding an array of objects.
    func testDecodeArrayOfObjects() {
        let method = JSFunction<[MockTarget]>("tester.testObjects")
        let expectedArray: [MockTarget] = [
            MockTarget(name: "Client", targetType: .app, categories: ["News", "Entertainment"]),
            MockTarget(name: "ClientTests", targetType: .unitTest, categories: ["DT", "Tests"])
        ]

        checkEvaluationResult(method, expectedValue: expectedArray)
    }

    /// Tests decoding an invalid array of objects.
    func testDecodeInvalidArrayOfObjects() {
        let method = JSFunction<[MockTarget]>("tester.testInvalidObjects")
        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: false))
    }

    /// Tests failure when decoding an array of invalid objects.
    func testDecodeInvalidObjectContainingArray() {
        let method = JSFunction<[MockTarget]>("tester.textMixedObjects")
        let expectedFailingValue: [AnyHashable] = [
            ["name": "Client", "targetType": "app", "categories": ["News"]] as NSDictionary,
            false
        ]

        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: expectedFailingValue))
    }

    /// Tests failure when the value is an array containing invalid prototypes.
    func testDecodeInvalidObjectPrototypeContainingArray() {
        let method = JSFunction<[MockTarget]>("tester.textDifferentObjectPrototypes")
        let expectedFailingValue: [AnyHashable] = [
            ["name": "Client", "targetType": "app", "categories": ["News"]] as NSDictionary,
            ["name": "SpaceTravelKit"] as NSDictionary,
        ]

        checkEvaluationResult(method, expectedFailure: .invalidReturnType(value: expectedFailingValue))
    }

}

// MARK: - Web View Support

extension ExecutionTests: WKNavigationDelegate {

    /// Checks that an expression returns the specified value.
    func checkEvaluationResult<Expression: JSExpression>(_ expression: Expression, expectedValue: Expression.ReturnType, file: StaticString = #file, line: UInt = #line) where Expression.ReturnType: Equatable {
        checkEvaluationResult(expression, file, line) { result in
            switch result {
            case .success(let successValue):
                XCTAssertEqual(successValue, expectedValue, file: file, line: line)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)", file: file, line: line)
            }
        }
    }

    /// Checks that an expression returns the specified error.
    func checkEvaluationResult<Expression: JSExpression>(_ expression: Expression, expectedFailure: JSErrorDomain, file: StaticString = #file, line: UInt = #line) where Expression.ReturnType: Equatable {
        checkEvaluationResult(expression, file, line) { result in
            switch result {
            case .success:
                XCTFail("Expected an error, but the evaluation succeded.", file: file, line: line)
            case .failure(let error):
                XCTAssertEqual(error.errorCode, expectedFailure.errorCode, "Invalid error: \(error)", file: file, line: line)
            }
        }
    }

    /// Checks that an expression can be evaluated.
    func checkEvaluationResult<Expression: JSExpression>(_ expression: Expression, _ file: StaticString = #file, _ line: UInt = #line, _ expectedResultChecker: @escaping (Result<Expression.ReturnType, JSErrorDomain>) -> Void) {
        let expectation = self.expectation(description: "")

        testInWebView(expectations: [expectation]) { webView in
            webView.evaluate(expression: expression) { result in
                expectedResultChecker(result)
                expectation.fulfill()
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        for action in actionQueue {
            action(webView)
        }
    }

    private func testInWebView(expectations: [XCTestExpectation] = [], timeout: TimeInterval = 10, _ webViewAction: @escaping (WKWebView) -> Void) {
        _queue(webViewAction)
        _launchActions()

        if expectations.count > 0 {
            wait(for: expectations, timeout: timeout)
        }
    }

    private func _queue(_ webViewAction: @escaping (WKWebView) -> Void) {
        actionQueue.append(webViewAction)
    }

    private func _launchActions() {
        webView.loadFileURL(resources.html, allowingReadAccessTo: resources.supportBundle)
    }

}
