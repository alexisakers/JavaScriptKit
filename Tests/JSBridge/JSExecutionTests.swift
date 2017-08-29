import XCTest
import WebKit
import Result
@testable import JSBridge

///
/// Teste l'éxécution d'expressions JavaScript dans une WebView.
///
/// ## Usage
/// Pour éxécuter un test dans la web view à partir d'une fonction:
///
/// ~~~swift
/// testInWebView {
///     webView in
///     // Faites les tests dans ce bloc.
/// }
/// ~~~
///
/// Vous pouvez utiliser des expectations dans le bloc `testInWebView`:
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
/// Le timeout pour une expectation est de 10s par défaut.
///
///

class JSExecutionTests: XCTestCase {

    /// La WebView où les tests seront éxécutés.
    var webView: WKWebView!

    /// Les URLs vers les ressources nécéssaires à l'éxécution des tests.
    let resources: (supportBundle: URL, html: URL) = {
        let bundleURL = Bundle(for: JSExecutionTests.self).resourceURL!
        let supportBundleURL = bundleURL.appendingPathComponent("JSBridgeTestsSupport.bundle", isDirectory: true)
        let htmlURL = supportBundleURL.appendingPathComponent("Tests.html", isDirectory: false)
        return (supportBundleURL, htmlURL)
    }()

    /// La queue des actions. Gérée automatiquement, ne pas modfier.
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

extension JSExecutionTests {

    ///
    /// Teste l'éxécution d'une expression qui récupère la valeur d'une propriété.
    ///

    func testProperty() {

        let property = JSVariable<String>("tester.title")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            property.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: "AppFoundation Tests")
            }

        }

    }

    ///
    /// Teste l'éxécution d'une expression qui appelle une fonction retournant
    /// une valeur du type attendu.
    ///

    func testSuccessReturnValue() {

        let method = JSFunction<Bool>("tester.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: true)
            }

        }

    }

    ///
    /// Teste l'éxécution d'une expression qui appelle une fonction retournant
    /// Void, le type attendu.
    ///

    func testVoidSuccessValue() {

        let method = JSFunction<Void>("tester.clearQueue")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: ())
            }

        }

    }

    ///
    /// Teste l'éxécution d'une expression qui retourne une erreur attendue.
    ///

    func testExpectedError() {

        let method = JSFunction<Void>("yolo.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertExecutionError(result)
            }

        }

    }

}


// MARK: - Test Invalid Value Handling

extension JSExecutionTests {

    ///
    /// Teste que l'expression retourne une erreur si une fonction qui devrait
    /// retourner Void retourne une valeur.
    ///

    func testHandleUnexpectedReturnValue() {

        let method = JSFunction<Void>("tester.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: true)
            }

        }

    }

    ///
    /// Teste que l'expression retourne une erreur si une fonction qui devrait
    /// retourner un certain type de valeur en retourne une autre.
    ///

    func testInvalidReturnValue() {

        let method = JSFunction<String>("tester.refresh")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: true)
            }

        }

    }

    ///
    /// Teste que l'expression retourne une erreur si une fonction qui devrait
    /// retourner une valeur n'en retourne pas.
    ///

    func testMissingReturnValue() {

        let method = JSFunction<Bool>("tester.clearQueue")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertUnexpectedResultError(result)
            }

        }

    }

}


// MARK: - Test JS to Native decoding

extension JSExecutionTests {

    // MARK: Primitives

    ///
    /// Teste le décodage d'une String.
    ///

    func testDecodeString() {

        let method = JSFunction<String>("tester.testString")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: "Hello, world!")
            }

        }

    }

    ///
    /// Teste le décodage d'un nombre.
    ///

    func testDecodeNumber() {

        let method = JSFunction<Int8>("tester.testNumber")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: 42)
            }

        }

    }

    ///
    /// Teste le décodage d'une Bool.
    ///

    func testDecodeBool() {

        let method = JSFunction<Bool>("tester.testBool")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: true)
            }

        }

    }

    ///
    /// Teste le décodage d'une Date.
    ///

    func testDecodeDate() {

        let method = JSFunction<Date>("tester.testDate")
        let resultExpectation = expectation(description: "Async execution callback is called")
        let testDate = Date(timeIntervalSince1970: 1500)

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: testDate)
            }

        }

    }

    // MARK: RawRepresentable

    ///
    /// Teste le décodage d'un RawRepresentable valide.
    ///

    func testDecodeValidRawRepresentable() {

        let method = JSFunction<MockTargetType>("tester.testValidMockTargetType")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: .app)
            }

        }

    }

    ///
    /// Teste le décodage d'un RawRepresentable invalide.
    ///

    func testDecodeInvalidRawRepresentable() {

        let method = JSFunction<MockTargetType>("tester.invalidTestMockTargetRawType")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: 100)
            }

        }

    }

    // MARK: Objects

    ///
    /// Teste le décodage d'un objet valide.
    ///

    func testDecodeObject() {

        let method = JSFunction<MockTarget>("tester.testTarget")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedTarget = MockTarget(name: "Client", targetType: .app, categories: ["News", "Entertainment"])

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedTarget)
            }

        }

    }

    ///
    /// Teste le décodage d'une valeur invalide lorsqu'un objet est attendu.
    ///

    func testDecodeInvalidObject() {

        let method = JSFunction<MockTarget>("tester.invalidTestTarget")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: false)
            }

        }

    }

    ///
    /// Teste le décodage d'un objet invalide.
    ///

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
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingPayload)
            }

        }

    }

    // MARK: Array of Primitives

    ///
    /// Teste le décodage d'un Array de primitives valide.
    ///

    func testDecodeArrayOfPrimitives() {

        let method = JSFunction<[UInt16]>("tester.testPrimitivesArray")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedArray: [UInt16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedArray)
            }

        }

    }

    ///
    /// Teste le décodage d'une valeur invalide lorsqu'un Array de
    /// primitives est attendu.
    ///

    func testDecodeInvalidArrayOfPrimitives() {

        let method = JSFunction<[UInt16]>("tester.testInvalidPrimitivesArray")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: "trolld")
            }

        }

    }

    ///
    /// Teste le décodage d'un Array de primitives invalide.
    ///

    func testDecodeInvalidMixedArrayOfPrimitives() {

        let method = JSFunction<[String]>("tester.testInvalidMixedPrimitivesArray")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingArray: [Any] = [1, "un", 2, "deux", 3, "trois"]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingArray)
            }

        }

    }


    // MARK: Array of RawRepresentable

    ///
    /// Teste le décodage d'un Array de RawRepresentable.
    ///

    func testDecodeArrayOfRawRepresentable() {

        let method = JSFunction<[MockTargetType]>("tester.testMockTargetTypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedValue: [MockTargetType] = [.app, .executable]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedValue)
            }

        }

    }

    ///
    /// Teste le décodage d'une valeur invalide lorsqu'un Array de
    /// RawRepresentable est attendu.
    ///

    func testDecodeInvalidArrayOfRawRepresentable() {

        let method = JSFunction<[MockTargetType]>("tester.testInvalidMockTargetTypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: false)
            }

        }

    }

    ///
    /// Teste le décodage d'une liste de valeurs incompatibles
    /// avec le type RawValue du type RawRepresentable testé.
    ///

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

    ///
    /// Teste le décodage d'une liste qui contient une valeur inconnue
    /// du type RawRepresentable testé.
    ///

    func testDecodeUnknownRawValue() {

        let method = JSFunction<[MockTargetType]>("tester.testUnknownRawMockTargetTypes")
        let resultExpectation = expectation(description: "Async execution callback is called")

        let expectedFailingArray = ["app", "kext"]

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingArray)
            }

        }

    }

    // MARK: Array of Object

    ///
    /// Teste le décodage d'un array d'objets.
    ///

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
                resultExpectation.fulfill()
                self.assertSuccess(result, expectedValue: expectedArray)
            }

        }

    }

    ///
    /// Teste le décodage d'une valeur invalide lorsqu'un Array
    /// d'objets est attendu.
    ///

    func testDecodeInvalidArrayOfObjects() {

        let method = JSFunction<[MockTarget]>("tester.testInvalidObjects")
        let resultExpectation = expectation(description: "Async execution callback is called")

        testInWebView(expectations: [resultExpectation]) {
            webView in

            method.evaluate(in: webView) {
                result in
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: false)
            }

        }

    }

    ///
    /// Teste le décodage d'un Array contenant des objets et des
    /// objets invalides.
    ///

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
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingValue)
            }

        }

    }

    ///
    /// Teste le décodage d'un Array contenant des objets et des
    /// objets d'un autre type.
    ///

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
                resultExpectation.fulfill()
                self.assertInvalidTypeError(result, expectedFailingValue: expectedFailingValue)
            }

        }

    }

}


// MARK: - Asserts

extension JSExecutionTests {

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

            }

        }

    }

}


// MARK: - Web View Support

extension JSExecutionTests: WKNavigationDelegate {

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
