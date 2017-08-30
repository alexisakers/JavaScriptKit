import XCTest
@testable import JavaScriptKit

///
/// Teste la génération et le décodage générique d'expressions JavaScript.
///

class JSGenericExpressionTests: XCTestCase {

    // MARK: - Test Value Decoding

    ///
    /// Teste que le décodage d'une valeur si le ReturnType est Void
    /// échoue toujours.
    ///

    func testVoidDecoding() {

        let expression = JSGenericExpression<Void>()

        let decodedValue: Void? = expression.decodeValue(())
        XCTAssertNil(decodedValue)

    }

    ///
    /// Teste le décodage d'une valeur primitive.
    ///

    func testPrimitiveDecoding() {

        let expression = JSGenericExpression<String>()

        let _decodedValue = expression.decodeValue("Hello")

        guard let decodedValue = _decodedValue else {
            XCTAssertNotNil(_decodedValue)
            return
        }

        XCTAssertEqual(decodedValue, "Hello")

    }

    ///
    /// Teste le décodage d'une valeur RawRepresentable.
    ///

    func testRawRepresentableDecoding() {

        let expression = JSGenericExpression<MockTargetType>()

        let _decodedValue = expression.decodeValue("appExtension")

        guard let decodedValue = _decodedValue else {
            XCTAssertNotNil(_decodedValue)
            return
        }

        XCTAssertEqual(decodedValue, MockTargetType.appExtension)

    }

    ///
    /// Teste le décodage d'un objet (NSDictionary).
    ///

    func testObjectDecoding() {

        let expression = JSGenericExpression<MockTarget>()

        let object: [String : Any] = [
            "name": "iPC",
            "targetType": "app",
            "categories": ["News", 1, "Entertainment", false]
        ]

        let _decodedValue = expression.decodeValue(object)

        guard let decodedValue = _decodedValue else {
            XCTAssertNotNil(_decodedValue)
            return
        }

        XCTAssertEqual(decodedValue.name, "iPC")
        XCTAssertEqual(decodedValue.targetType, .app)
        XCTAssertEqual(decodedValue.categories, ["News", "Entertainment"])

    }


    // MARK: - Test Sequence Decoding

    ///
    /// Teste le décodage d'une séquence de valeurs primitives.
    ///

    func testPrimitiveSequenceDecoding() {

        let expression = JSGenericExpression<[String]>()

        let sequence: [String] = [
            "Hello", " ", "world", "!"
        ]

        let _decodedSequence = expression.decodeValue(sequence)

        guard let decodedSequence = _decodedSequence else {
            XCTAssertNotNil(_decodedSequence)
            return
        }

        XCTAssertEqual(decodedSequence, sequence)

    }

    ///
    /// Teste le décodage d'une séquence de valeurs RawRepresentable.
    ///

    func testRawRepresentableSequenceDecoding() {

        let expression = JSGenericExpression<[MockTargetType]>()

        let sequence = [
            "app", "appExtension", "unitTest", "uiTest"
        ]

        let _decodedSequence = expression.decodeValue(sequence)

        guard let decodedSequence = _decodedSequence else {
            XCTAssertNotNil(_decodedSequence)
            return
        }

        let expectedSequence: [MockTargetType] = [
            .app, .appExtension, .unitTest, .uiTest
        ]

        XCTAssertEqual(decodedSequence, expectedSequence)

    }

    ///
    /// Teste le décodage d'une séquence d'objets.
    ///

    func testObjectSequenceDecoding() {

        let expression = JSGenericExpression<[MockTarget]>()

        let sequence = [
            [
                "name": "Client",
                "targetType": "app",
                "categories": ["News", 1, "Entertainment", false]
            ],
            [
                "name": "ClientTests",
                "targetType": "unitTest",
                "categories": ["DT", "Tests"]
            ]
        ]

        let _decodedSequence = expression.decodeValue(sequence)

        guard let decodedSequence = _decodedSequence else {
            XCTAssertNotNil(_decodedSequence)
            return
        }

        let expectedSequence: [MockTarget] = [
            MockTarget(name: "Client", targetType: .app, categories: ["News", "Entertainment"]),
            MockTarget(name: "ClientTests", targetType: .unitTest, categories: ["DT", "Tests"])
        ]

        XCTAssertEqual(decodedSequence, expectedSequence)

    }

}

// MARK: - Mock Data

enum MockTargetType: String {
    case app, appExtension, unitTest, uiTest, executable
}

class MockTarget: JSObject, Equatable {

    let name: String
    let targetType: MockTargetType
    let categories: [String]

    init(name: String, targetType: MockTargetType, categories: [String]) {
        self.name = name
        self.targetType = targetType
        self.categories = categories
    }

    required init?(objectLiteral dictionary: NSDictionary) {

        guard let name = dictionary.value(forKey: "name") as? String else {
            return nil
        }

        guard let targetTypeString = dictionary.value(forKey: "targetType") as? String else {
            return nil
        }

        guard let targetType = MockTargetType(rawValue: targetTypeString) else {
            return nil
        }

        guard let categoriesArray = dictionary.value(forKey: "categories") as? NSArray else {
            return nil
        }

        self.name = name
        self.targetType = targetType
        self.categories = categoriesArray.flatMap { $0 as? String }

    }

    static func == (lhs: MockTarget, rhs: MockTarget) -> Bool {
        return (lhs.name == rhs.name) && (lhs.targetType == rhs.targetType) && (lhs.categories == rhs.categories)
    }

}

class JSGenericExpression<T>: JSExpression {

    typealias ReturnType = T

    func makeExpressionString() -> String {
        return "undefined"
    }

}
