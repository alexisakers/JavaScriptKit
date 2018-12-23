# _JavaScriptKit_ Changelog

## 🔖 v2.0.0

### New Features

- Cleaner API: the web view is now responsible for evaluating the expression, to align with the existing WebKit API (`WKWebView.execute(expression:completionHandler:)`)

### Changes

- Remove dependency on `Result`, we will migrate to the native type when Swift 5 is available
- Move to Swift 4.2 and Xcode 10
- Update documentation
- Simplified tests

## 🔖 v1.0.0

- Inital Release
