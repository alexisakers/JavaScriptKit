//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation
import CoreGraphics

/**
 * The `Void` return value.
 */

public struct JSVoid: Equatable, Decodable {

    /// Compares two Void values. Always evaluates to `true`.
    public static func == (lhs: JSVoid, rhs: JSVoid) -> Bool { return true }

}

// MARK: - Helpers

/**
 * A type providing either a success or an error value, from the result of an operation.
 * - note: This can be removed when migrating to Swift 5.
 */

public enum Result<Success, Failure: Swift.Error> {

    /// The operation succeeded and returned a value.
    case success(Success)

    /// The operation failed and returned an error.
    case failure(Failure)

}
