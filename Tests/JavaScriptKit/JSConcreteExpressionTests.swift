import XCTest
@testable import JavaScriptKit

///
/// Teste la génération de scripts à partir d'une expression concrète.
///

class JSConcreteExpressionTests: XCTestCase {

    ///
    /// Teste la génération d'un script pour accéder à une propriété.
    ///

    func testPropertyScript() {

        let property = JSVariable<Bool>("reader.isLoaded")

        let script = property.makeExpressionString()
        let expectedScript = "this.reader.isLoaded;"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode sans arguments.
    ///

    func testNoArgumentsMethod() {

        let method = JSFunction<Bool>("reader.sendStats")

        let script = method.makeExpressionString()
        let expectedScript = "this.reader.sendStats();"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode avec un seul argument.
    ///

    func testSingleArgumentMethod() {

        let method = JSFunction<Bool>("reader.setNumberOfParagraphsRead", arguments: 1)

        let script = method.makeExpressionString()
        let expectedScript = "this.reader.setNumberOfParagraphsRead(1);"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode avec plusieurs arguments.
    ///

    func testMultipleArgumentsMethod() {

        let method = JSFunction<Bool>("reader.setParagraphRead", arguments: "5DE741DD", true, Date(timeIntervalSince1970: 1500))

        let script = method.makeExpressionString()
        let expectedScript = "this.reader.setParagraphRead(\"5DE741DD\", true, new Date(1500000));"
        XCTAssertEqual(script, expectedScript)

    }

    ///
    /// Teste la génération d'un script pour une méthode avec plusieurs arguments RawRepresentable.
    ///

    func testRawRepresentableArguments() {

        let method = JSFunction<Bool>("reader.setFont", arguments: MockFont.sanFrancisco, MockSize.large)

        let script = method.makeExpressionString()
        let expectedScript = "this.reader.setFont(\"sanFrancisco\", 17);"
        XCTAssertEqual(script, expectedScript)

    }
    
}

enum MockFont: String, JSConvertible {
    case sanFrancisco
}

enum MockSize: Int, JSConvertible {
    case large = 17
}
