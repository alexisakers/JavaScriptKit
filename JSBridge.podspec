#
#  Be sure to run `pod spec lint JSBridge.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "JSBridge"
  s.version      = "1.0.0"
  s.summary      = "JavaScript Expression Evaluator for WKWebView."

  s.description  =
<<-DESC
JSBridge is a replacement for JavaScriptCore in WKWebView. Generate and evaluate type-safe JavaScript expressions. Automatically convert objects and enumeration cases. Easily check for errors.
DESC

  s.homepage     = "https://github.com/alexaubry/JSBridge"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Alexis Aubry" => "me@alexaubry.fr" }
  s.social_media_url   = "http://twitter.com/_alexaubry"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/alexaubry/JSBridge.git" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Sources/**/*.swift"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.resource_bundles      = { "JSBridge" => ["Locales/**/*.lproj"] }

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.frameworks = "Foundation", "WebKit"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.dependency "Result", "~> 3.1"

end
