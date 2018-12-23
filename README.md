# JavaScriptKit

[![Build Status](https://dev.azure.com/alexaubry/JavaScriptKit/_apis/build/status/alexaubry.JavaScriptKit?branchName=master)](https://dev.azure.com/alexaubry/JavaScriptKit/_build/latest?definitionId=4?branchName=master)[![Version](https://img.shields.io/cocoapods/v/JavaScriptKit.svg?style=flat)](http://cocoapods.org/pods/JavaScriptKit)
[![License](https://img.shields.io/cocoapods/l/JavaScriptKit.svg?style=flat)](http://cocoapods.org/pods/JavaScriptKit)
[![Platform](https://img.shields.io/cocoapods/p/JavaScriptKit.svg?style=flat)](http://cocoapods.org/pods/JavaScriptKit)

JavaScriptKit is a powerful replacement for JavaScriptCore to use with your WebKit web views. Supports iOS and macOS.

## Features

- Generate and evaluate type-safe JavaScript expressions in WKWebView
- Automatically encode and decode values, JSON objects and enumerations to and from JavaScript
- Easy error handling
- [Documented](https://alexaubry.github.io/JavaScriptKit)

## Installation

### CocoaPods

To use CocoaPods, add the following to your Podfile:

```ruby
pod 'JavaScriptKit', '~> 2.0'
```

### Carthage

To use Carthage, add the following to your Cartfile:

```ogdl
github "alexaubry/JavaScriptKit" ~> 2.0
```
## Versions

| | 1.0.x | 2.0.x |
|---|---|---|
| Minimum iOS Version | 8.0 | 8.0 |
| Minimum macOS Version | 10.10 | 10.10 |
| Supported Swift Version(s) | 4.0.x | 4.2.x |

## How it works

The library is structured around the `JSExpression` protocol. Expressions can be represented as a JavaScript expression string, and have their return type defined at compile-time for better type safety.

You can evaluate expressions inside of a `WKWebView`. You provide a callback block that will be called with a `Result` object, containing either the value returned on success, or the error thrown by the web view on failure. Callback blocks are always executed on the main thread.

When the web view returns the result, `JavaScriptKit` uses a custom [`Decoder`](https://developer.apple.com/documentation/swift/decoder) to decode it into the return type you specified. This allows you to set the return type to any [`Decodable`](https://developer.apple.com/documentation/swift/decodable) type (structures, classes, primitive types, enumeration, array, dictionary, ...).

## Usage

### Get the value of a variable

Use the `JSVariable` expression type to get the value of a variable at the specified key path.

#### Example 1.1

> Get the title of the current document

~~~swift
let titleVariable = JSVariable<String>("document.title")

webView.evaluate(expression: titleVariable) { result in
    switch result {
    case .success(let title):
        // do something with the `title` string

    case .failure(let error):
        // handle error
    }
}
~~~

- The `title` value provided on success is a `String`.

### Call a function

Use the `JSFunction` expression type to call a function at the specified key path. You can pass as many arguments as needed. They must conform to the `Encodable` protocol to be converted to a JavaScript representation.

When the function does not return a value, use the `JSVoid` return type.

#### Example 2.1

> URI-Encode a String

~~~swift
let encodeURI = JSFunction<String>("window.encodeURI", arguments: "Hello world")

webView.evaluate(expression: encodeURI) { result in
    switch result {
    case .success(let encodedURI):
        // do something with the `encodedURI` string

    case .failure(let error):
        // handle error
    }
}
~~~

- The `alert` expression will be converted to: `"this.window.encodeURI("Hello world");"`.
- The `encodedURI` value provided on success is a `String`.

#### Example 2.2

> Show an alert

~~~swift
let alert = JSFunction<JSVoid>("window.alert", arguments: "Hello from Swift!")
webView.evaluate(expression: alert, completionHandler: nil)
~~~

- The `alert` expression will be converted to: `"this.window.alert("Hello from Swift!");"`.
- To ignore the result of the expression, pass `nil` for the `completionHandler` argument.

#### Example 2.3

> Reload the window

~~~swift
let reload = JSFunction<JSVoid>("location.reload")

webView.evaluate(expression: reload, completionHandler: nil)
~~~

- You can omit the `arguments` parameter if the function takes no arguments.

### Run your custom scripts

Use the `JSScript` expression type to run your custom scripts. To create custom scripts, you define a `String` that contains the script to run and define the return value.

The last evaluated statement in your script will be used as the return value. Do not use `return` at the end of the script, as it would yield an invalid value.

#### Example 3.1

> Get the time of the day from a time string in the document

~~~swift
enum TimeOfDay: String, Decodable {
    case night, morning, afternoon, evening
}

let scriptBody = """
function getTimeOfDay(hour) {

    if (hour >= 0 && hour < 6) {
        return "night";
    } else if (hour >= 6 && hour < 12) {
        return "morning"
    } else if (hour >= 12 && hour < 18) {
        return "afternoon"
    } else if (hour >= 18 && hour > 0) {
        return "evening"
    }

}

var postPublishDate = document.getElementById("publish-date").innerHTML
var hours = new Date(postPublishDate).getHours();

getTimeOfDay(hours);
"""

let script = JSScript<TimeOfDay>(scriptBody)

webView.evaluate(expression: script) { result in

    switch result {
    case .success(let timeOfDay):
        // do something with the `timeOfDay` object

    case .failure(let error):
        // handle error
    }

}
~~~

- The `timeOfDay` value provided on success is a case of `TimeOfDay`.
- `TimeOfDay` is a supported return type because it implements the `Decodable` protocol.

## Contributing

Contributions are welcome and appreciated! Here's how you should submit contributions:

- Fork and clone the repository
- Create a new branch for your fixes (ex: `git checkout -b [your branch name]`)
- Get the development dependencies by running `carthage bootstrap`
- Add your changes and commit them to your branch
- Submit a PR to the `master` branch

If you find a bug or think a feature is missing, please [submit an issue](https://github.com/alexaubry/JavaScriptKit/issues).

## Authors

Alexis Aubry, me@alexaubry.fr <[@_alexaubry](https://twitter.com/_alexaubry)>

## License

JavaScriptKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
