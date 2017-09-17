import XCTest
import WebKit
import Result
@testable import JavaScriptKit

///
/// Tests executing JavaScript expressions inside a web view.
///
/// ## Usage
/// To execute tests:
///
/// ~~~swift
/// testInWebView {
///     webView in
///     // Run your tests in this block.
/// }
/// ~~~
///
/// You can also use expectations in `testInWebView`:
///
/// ~~~swift
/// let callbackExpectation = expectation(description: "...")
///
/// testInWebView(expectations: [callbackExpectation] {
///     webView in
///     callbackExpectation.fullfill()
/// }
/// ~~~
///
/// The default timeout is 10s.
///
///

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
    }

}


// MARK: - Test Expected Results

extension ExecutionTests {

    /// Tests getting a property.
    func testProperty() {

        let property = JSVariable<String>("tester.title")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            property.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: "AppFoundation Tests")
            }

        }

    }

    /// Tests executing a function that returns a value of the expected type.
    func testSuccessReturnValue() {

        let method = JSFunction<Bool>("tester.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: true)
            }

        }

    }

    /// Tests executing a function that returns Void.
    func testVoidSuccessValue() {

        let method = JSFunction<JSVoid>("tester.clearQueue")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: JSVoid())
            }

        }

    }

    /// Tests that an error is thrown when the function does not exist.
    func testExpectedError() {

        let method = JSFunction<JSVoid>("yolo.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertExecutionError(result)
            }

        }

    }

}


// MARK: - Test Invalid Value Handling

extension ExecutionTests {

    /// Tests that an error is thrown when a value is returned and Void is expected.
    func testHandleUnexpectedReturnValue() {

        let method = JSFunction<JSVoid>("tester.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: true)
            }

        }

    }

    /// Tests that an error is thrown when the type is mismatching.
    func testInvalidReturnValue() {

        let method = JSFunction<String>("tester.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: true)
            }

        }

    }

    /// Tests that an error is thrown when the function does not return a value.
    func testMissingReturnValue() {

        let method = JSFunction<Bool>("tester.clearQueue")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertUnexpectedResultError(result)
            }

        }

    }

}


// MARK: - Test JS to Native decoding

extension ExecutionTests {

    // MARK: Primitives

    /// Tests decoding a String.
    func testDecodeString() {

        let method = JSFunction<String>("tester.testString")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: "Hello, world!")
            }

        }

    }

    /// Tests decoding a number.
    func testDecodeNumber() {

        let method = JSFunction<Int8>("tester.testNumber")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: 42)
            }

        }

    }

    /// Tests decoding a Bool.
    func testDecodeBool() {

        let method = JSFunction<Bool>("tester.testBool")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: true)
            }

        }

    }

    /// Tests decoding a Date.
    func testDecodeDate() {

        let method = JSFunction<Date>("tester.testDate")
        let resultExpectation = expectation(description: "Async execution callback is called")
        let testDate = Date(timeIntervalSince1970: 1500)

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: testDate)
            }

        }

    }

    // MARK: RawRepresentable

    /// Tests decoding a RawRepresentable.
    func testDecodeValidRawRepresentable() {

        let method = JSFunction<MockTargetType>("tester.testValidMockTargetType")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: .app)
            }

        }

    }

    /// Tests decoding an invalid RawRepresentable.
    func testDecodeInvalidRawRepresentable() {

        let method = JSFunction<MockTargetType>("tester.invalidTestMockTargetRawType")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: 100)
            }

        }

    }

    // MARK: Objects

    /// Tests decoding an object.
    func testDecodeObject() {

        let method = JSFunction<MockTarget>("tester.testTarget")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedTarget = MockTarget(name: "Client", targetType: .app, categories: ["News", "Entertainment"])

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedTarget)
            }

        }

    }

    /// Tests failure when an object is expected but a primitive is returned.
    func testDecodeInvalidObject() {

        let method = JSFunction<MockTarget>("tester.invalidTestTarget")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: false)
            }

        }

    }

    /// Tests decoding failure.
    func testDecodeInvalidObjectPrototype() {

        let method = JSFunction<MockTarget>("tester.invalidTestTargetPrototype")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingPayload: [AnyHashable : Any] = [
            "name": "Client",
            "targetType": "app",
            "categories": NSNull()
        ]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingPayload)
            }

        }

    }

    // MARK: Array of Primitives

    /// Tests decoding an array of primitives.
    func testDecodeArrayOfPrimitives() {

        let method = JSFunction<[UInt16]>("tester.testPrimitivesArray")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedArray: [UInt16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedArray)
            }

        }

    }

    /// Tests decoding and invalid array of primitives.
    func testDecodeInvalidArrayOfPrimitives() {

        let method = JSFunction<[UInt16]>("tester.testInvalidPrimitivesArray")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: "trolld")
            }

        }

    }

    /// Tests decoding an array of invalid primitives (mixed types).
    func testDecodeInvalidMixedArrayOfPrimitives() {

        let method = JSFunction<[String]>("tester.testInvalidMixedPrimitivesArray")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingArray: [Any] = [1, "un", 2, "deux", 3, "trois"]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingArray)
            }

        }

    }


    // MARK: Array of RawRepresentable

    /// Tests decoding an array of Raw Representables.
    func testDecodeArrayOfRawRepresentable() {

        let method = JSFunction<[MockTargetType]>("tester.testMockTargetTypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedValue: [MockTargetType] = [.app, .executable]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedValue)
            }

        }

    }

    /// Tests decoding an array of invalid raw representable values.
    func testDecodeInvalidArrayOfRawRepresentable() {

        let method = JSFunction<[MockTargetType]>("tester.testInvalidMockTargetTypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: false)
            }

        }

    }

    /// Tests decoding an array that doesnt match the expected raw type.
    func testDecodeInvalidRawTypesArray() {

        let method = JSFunction<[MockTargetType]>("tester.testInvalidRawMockTargetTypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingArray = [1, 2, 3]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingArray)
            }

        }

    }

    /// Tests decoding an unknown raw value.
    func testDecodeUnknownRawValue() {

        let method = JSFunction<[MockTargetType]>("tester.testUnknownRawMockTargetTypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingArray = ["app", "kext"]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingArray)
            }

        }

    }

    // MARK: Array of Object

    /// Tests decoding an array of objects.
    func testDecodeArrayOfObjects() {

        let method = JSFunction<[MockTarget]>("tester.testObjects")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedArray: [MockTarget] = [
            MockTarget(name: "Client", targetType: .app, categories: ["News", "Entertainment"]),
            MockTarget(name: "ClientTests", targetType: .unitTest, categories: ["DT", "Tests"])
        ]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedArray)
            }

        }

    }

    /// Tests decoding an invalid array of objects.
    func testDecodeInvalidArrayOfObjects() {

        let method = JSFunction<[MockTarget]>("tester.testInvalidObjects")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: false)
            }

        }

    }

    /// Tests failure when decoding an array of invalid objects.
    func testDecodeInvalidObjectContainingArray() {

        let method = JSFunction<[MockTarget]>("tester.textMixedObjects")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingValue: [AnyHashable] = [
            ["name": "Client", "targetType": "app", "categories": ["News"]] as NSDictionary,
            false
        ]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingValue)
            }

        }

    }

    /// Tests failure when the value is an array containing invalid prototypes.
    func testDecodeInvalidObjectPrototypeContainingArray() {

        let method = JSFunction<[MockTarget]>("tester.textDifferentObjectPrototypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingValue: [AnyHashable] = [
            ["name": "Client", "targetType": "app", "categories": ["News"]] as NSDictionary,
            ["name": "SpaceTravelKit"] as NSDictionary,
        ]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                assert(Thread.isMainThread)
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingValue)
            }

        }

    }

}


// MARK: - Asserts

extension ExecutionTests {

    ///
    /// S'assure que le résultat est un succès contenant la valeur donnée.
    ///

    func assertSuccess<R: Equatable, E>(_ result: Result<R, E>, expectedValue: R) {

        switch result {
        case .success(let value):
            XCTAssertEqual(value, expectedValue)

        case .failure(let error):
            XCTFail("Erreur innatendue : \(error)")
        }

    }

    ///
    /// S'assure que le résultat est un succès contenant la valeur donnée.
    ///

    func assertSuccess<E>(_ result: Result<Void, E>, expectedValue: Void) {

        switch result {
        case .success(let value):
            XCTAssertTrue(value == ())

        case .failure(let error):
            XCTFail("Erreur innatendue : \(error)")
        }

    }

    ///
    /// S'assure que le résultat est un succès contenant la valeur donnée.
    ///

    func assertSuccess<R: Equatable, E>(_ result: Result<[R], E>, expectedValue: Array<R>) {

        switch result {
        case .success(let value):
            XCTAssertEqual(value, expectedValue)

        case .failure(let error):
            XCTFail("Erreur innatendue : \(error)")
        }

    }

    ///
    /// S'assure que le résultat est un échec de type causé par une mauvaise valeur donnée.
    ///

    func assertInvalidTypeError<R, T: Equatable>(_ result: Result<R, JSErrorDomain>, expectedFailingValue: T) {

        switch result {
        case .success(_):
            XCTFail("Une valeur a été retournée, alors qu'une erreur de type `invalidReturnType` était attendue.")

        case .failure(let error):

            switch error {
            case .invalidReturnType(let value):
                XCTAssertTrue((value as? T) == expectedFailingValue, "Une erreur de type a bien été retournée, mais la valeur posant problème ne correspond pas à celle attendue.")
                XCTAssertEqual(error.nsError.domain, JSErrorDomain.identifier, "L'erreur ne provient pas du domaine attendu.")

            case .executionError(_):
                XCTFail("Une erreur de type `executionError` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")

            case .unexpectedResult:
                XCTFail("Une erreur de type `unexpectedResult` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")

            case .invalidExpression(_):
                XCTFail("Une erreur de type `invalidExpression` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")


            }

        }

    }

    ///
    /// S'assure que le résultat est un échec de type causé par une mauvaise valeur donnée.
    ///

    func assertInvalidTypeError<R>(_ result: Result<[R], JSErrorDomain>, expectedFailingValue: [Any]) {

        switch result {
        case .success(_):
            XCTFail("Une valeur a été retournée, alors qu'une erreur de type `invalidReturnType` était attendue.")

        case .failure(let error):

            switch error {
            case .invalidReturnType(let value):
                XCTAssertTrue((value as? NSArray)?.isEqual(to: expectedFailingValue) == true, "Une erreur de type a bien été retournée, mais la valeur posant problème ne correspond pas à celle attendue.")
                XCTAssertEqual(error.nsError.domain, JSErrorDomain.identifier, "L'erreur ne provient pas du domaine attendu.")

            case .executionError(_):
                XCTFail("Une erreur de type `executionError` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")

            case .unexpectedResult:
                XCTFail("Une erreur de type `unexpectedResult` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")

            case .invalidExpression(_):
                XCTFail("Une erreur de type `unexpectedResult` a été retournée alors qu'une erreur de type `invalidExpression` était attendue.")

            }

        }

    }

    ///
    /// S'assure que le résultat est un échec de type causé par une mauvaise valeur donnée.
    ///

    func assertInvalidTypeError<R>(_ result: Result<R, JSErrorDomain>, expectedFailingValue: [AnyHashable : Any]) {

        switch result {
        case .success(_):
            XCTFail("Une valeur a été retournée, alors qu'une erreur de type `invalidReturnType` était attendue.")

        case .failure(let error):

            switch error {
            case .invalidReturnType(let value):
                XCTAssertTrue((value as? NSDictionary)?.isEqual(to: expectedFailingValue) == true, "Une erreur de type a bien été retournée, mais la valeur posant problème ne correspond pas à celle attendue.")
                XCTAssertEqual(error.nsError.domain, JSErrorDomain.identifier, "L'erreur ne provient pas du domaine attendu.")

            case .executionError(_):
                XCTFail("Une erreur de type `executionError` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")

            case .unexpectedResult:
                XCTFail("Une erreur de type `unexpectedResult` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")

            case .invalidExpression(_):
                XCTFail("Une erreur de type `invalidExpression` a été retournée alors qu'une erreur de type `invalidReturnType` était attendue.")


            }

        }

    }


    ///
    /// S'assure que le résultat est un échec contenant le type donnée.
    ///

    func assertExecutionError<R>(_ result: Result<R, JSErrorDomain>) {

        switch result {
        case .success(_):
            XCTFail("Une valeur a été retournée, alors qu'une erreur de type `executionError` était attendue.")

        case .failure(let error):

            switch error {
            case .invalidReturnType(_):
                XCTFail("Une erreur de type `invalidReturnType` a été retournée alors qu'une erreur de type `executionError` était attendue.")

            case .executionError(_):
                XCTAssertEqual(error.nsError.domain, JSErrorDomain.identifier, "L'erreur ne provient pas du domaine attendu.")

            case .unexpectedResult:
                XCTFail("Une erreur de type `unexpectedResult` a été retournée alors qu'une erreur de type `executionError` était attendue.")

            case .invalidExpression(_):
                XCTFail("Une erreur de type `invalidExpression` a été retournée alors qu'une erreur de type `executionError` était attendue.")

            }

        }

    }

    ///
    /// S'assure que le résultat est un échec contenant le type donnée.
    ///

    func assertUnexpectedResultError<R>(_ result: Result<R, JSErrorDomain>) {

        switch result {
        case .success(_):
            XCTFail("Une valeur a été retournée, alors qu'une erreur de type `unexpectedResult` était attendue.")

        case .failure(let error):

            switch error {
            case .invalidReturnType(_):
                XCTFail("Une erreur de type `invalidReturnType` a été retournée alors qu'une erreur de type `unexpectedResult` était attendue.")

            case .executionError(_):
                XCTFail("Une erreur de type `executionError` a été retournée alors qu'une erreur de type `unexpectedResult` était attendue.")

            case .unexpectedResult:
                XCTAssertEqual(error.nsError.domain, JSErrorDomain.identifier, "L'erreur ne provient pas du domaine attendu.")

            case .invalidExpression(_):
                XCTFail("Une erreur de type `invalidExpression` a été retournée alors qu'une erreur de type `unexpectedResult` était attendue.")

            }

        }

    }

}


// MARK: - Web View Support

extension ExecutionTests: WKNavigationDelegate {

    ///
    /// Éxécute un test dans la WebView.
    ///
    /// Cette méthode ne doit être utilisée qu'une seule fois par fonction de test.
    ///
    /// - parameter expectations: Une éventuelle liste d'expectations utilisées dans le bloc de test.
    /// - parameter timeout: Le timeout pour les `expecations`. Par défaut, 10 secondes.
    /// - parameter webViewAction: Le bloc de test à éxécuter une fois que la WebView a fini de charger les
    /// éléments de test.
    ///

    func testInWebView(expectations: [XCTestExpectation] = [],
                       timeout: TimeInterval = 10,
                       _ webViewAction: @escaping (WKWebView) -> Void) {

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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        for action in actionQueue {
            action(webView)
        }

    }

}
