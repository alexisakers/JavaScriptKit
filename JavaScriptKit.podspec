Pod::Spec.new do |s|
  s.name         = "JavaScriptKit"
  s.version      = "1.0.0"
  s.summary      = "JavaScriptCore replacement for WKWebView"

  s.description  =
<<-DESC
JavaScriptKit is a powerful replacement for JavaScriptCore to use with your WebKit web views. Generate and evaluate type-safe JavaScript expressions in WKWebView. Automatically encode and decode values, JSON objects and enumerations to and from JavaScript. Easily handle errors.
DESC

  s.homepage     = "https://github.com/alexaubry/JavaScriptKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Alexis Aubry" => "me@alexaubry.fr" }
  s.social_media_url   = "http://twitter.com/_alexaubry"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/alexaubry/JavaScriptKit.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.swift"
  s.resource_bundles      = { "JavaScriptKit" => ["Locales/**/*.lproj"] }

  s.frameworks = "Foundation", "WebKit"
  s.dependency "Result", "~> 3.1"

  s.documentation_url = "https://alexaubry.github.io/JavaScriptKit"
end
