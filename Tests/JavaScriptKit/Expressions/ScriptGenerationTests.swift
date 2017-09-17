import XCTest
@testable import JavaScriptKit

///
/// Tests generating scripts from expressions.
///

class ScriptGenerationTests: XCTestCase {

    /// Tests generating a property accessing script.
    func testPropertyScript() throws {
        let property = JSVariable<Bool>("reader.isLoaded")
        let expectedScript = "this.reader.isLoaded;"
        try assertGeneratedScript(for: property, isEqualTo: expectedScript)
    }

    /// Tests generating a script for a function that takes no arguments.
    func testNoArgumentsMethod() throws {
        let method = JSFunction<Bool>("reader.sendStats")
        let expectedScript = "this.reader.sendStats();"
        try assertGeneratedScript(for: method, isEqualTo: expectedScript)
    }

    /// Tests generating a script for a function that takes one argument.
    func testSingleArgumentMethod() throws {
        let method = JSFunction<Bool>("reader.setNumberOfParagraphsRead", arguments: 1)
        let expectedScript = "this.reader.setNumberOfParagraphsRead(1);"
        try assertGeneratedScript(for: method, isEqualTo: expectedScript)
    }

    /// Tests generating a script for a function that takes multiple arguments.
    func testMultipleArgumentsMethod() throws {
        let method = JSFunction<Bool>("reader.setParagraphRead", arguments: "5DE741DD", true, Date(timeIntervalSince1970: 1500))
        let expectedScript = "this.reader.setParagraphRead(\"5DE741DD\", true, new Date(1500000));"
        try assertGeneratedScript(for: method, isEqualTo: expectedScript)
    }

    /// Tests generating a script for a function that takes a Raw Representable argument.
    func testRawRepresentableArguments() throws {
        let method = JSFunction<Bool>("reader.setFont", arguments: ReaderFont.sanFrancisco, ReaderSize.large)
        let expectedScript = "this.reader.setFont(\"sanFrancisco\", 17);"
        try assertGeneratedScript(for: method, isEqualTo: expectedScript)
    }

    /// Tests generating a script for a custom script.
    func testCustomScript() throws {

        let javaScriptString = """
        function getRandom() {
            return Math.random();
        }

        getRandom();
        """

        let script = JSScript<Double>(javaScriptString)
        try assertGeneratedScript(for: script, isEqualTo: javaScriptString)

    }

    // MARK: Helpers

    /// Asserts that the generated script is equal to the expected script.
    func assertGeneratedScript<T: JSExpression>(for expression: T, isEqualTo expectedScript: String) throws {
        let script = try expression.makeExpressionString()
        XCTAssertEqual(script, expectedScript)
    }
    
}
