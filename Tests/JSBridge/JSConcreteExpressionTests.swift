import XCTest
@testable import JSBridge

///
/// Teste la génération de scripts à partir d'une expression concrète.
///

class JSConcreteExpressionTests: XCTestCase {

    ///
    /// Teste la génération d'un script pour accéder à une propriété.
    ///

    func testPropertyScript() {

        let property = JSProperty<Bool>(variableName: "reader", "isLoaded")

        let script = property.javaScriptString
        let expectedScript = "reader.isLoaded"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode sans arguments.
    ///

    func testNoArgumentsMethod() {

        let method = JSMethod<Bool>(variableName: "reader", "sendStats")

        let script = method.javaScriptString
        let expectedScript = "reader.sendStats()"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode avec un seul argument.
    ///

    func testSingleArgumentMethod() {

        let method = JSMethod<Bool>(variableName: "reader", "setNumberOfParagraphsRead", 1)

        let script = method.javaScriptString
        let expectedScript = "reader.setNumberOfParagraphsRead(1)"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode avec plusieurs arguments.
    ///

    func testMultipleArgumentsMethod() {

        let method = JSMethod<Bool>(variableName: "reader", "setParagraphRead", "5DE741DD", true)

        let script = method.javaScriptString
        let expectedScript = "reader.setParagraphRead(\"5DE741DD\", true)"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode avec plusieurs arguments RawRepresentable.
    ///

    func testRawRepresentableArguments() {

        let method = JSMethod<Bool>(variableName: "reader", "setFont", MockFont.sanFrancisco, MockSize.large)

        let script = method.javaScriptString
        let expectedScript = "reader.setFont(\"sanFrancisco\", 17)"
        XCTAssertEqual(script, expectedScript)

    }
    
}

enum MockFont: String, JSConvertible {
    case sanFrancisco
}

enum MockSize: Int, JSConvertible {
    case large = 17
}
