/**
 *  JavaScriptKit
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import CoreGraphics

///
/// The `Void` return value.
///

public struct JSVoid: Equatable, Decodable {

    /// Compares two Void values. Always evaluates to `true`.
    public static func == (lhs: JSVoid, rhs: JSVoid) -> Bool { return true }

}
