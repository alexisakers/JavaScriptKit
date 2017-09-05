Pod::Spec.new do |s|
  s.name         = "JavaScriptKit"
  s.version      = "1.0.0"
  s.summary      = "JavaScript Toolkit for WKWebView"

  s.description  =
<<-DESC
Evaluate JavaScript programs from within a WebKit web view. Generate and evaluate type-safe JavaScript expressions. Automatically convert objects and enumeration cases from and to JavaScript. Easily check for errors.
DESC

  s.homepage     = "https://github.com/alexaubry/JavaScriptKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Alexis Aubry" => "me@alexaubry.fr" }
  s.social_media_url   = "http://twitter.com/_alexaubry"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/alexaubry/JavaScriptKit", :tag => #{s.version} }
  s.source_files  = "Sources/**/*.swift"
  s.resource_bundles      = { "JavaScriptKit" => ["Locales/**/*.lproj"] }

  s.frameworks = "Foundation", "WebKit"
  s.dependency "Result", "~> 3.1"
end
