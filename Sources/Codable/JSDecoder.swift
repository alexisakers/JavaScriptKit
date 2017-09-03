/**
 *  JavaScriptKit
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// Decodes JavaScript expression return values to a `Decodable` value.
///

final class JSDecoder {

    func decode<T: Decodable>(_ value: Any) throws -> T {
        throw NSError()
    }

}
