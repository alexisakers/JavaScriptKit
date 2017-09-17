/**
 *  JavaScriptKit
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import CoreGraphics

///
/// The `Void` return value.
///

public final class JSVoid: Decodable {
    public init() {}
    public init(from decoder: Decoder) {}
}
