Pod::Spec.new do |s|
  s.name         = "AQSPocketActivity"
  s.version      = "0.1.1"
  s.summary      = "[iOS] UIActivity Class for Pocket"
  s.homepage     = "https://github.com/AquaSupport/AQSPocketActivity"
  s.license      = "MIT"
  s.author       = { "kaiinui" => "lied.der.optik@gmail.com" }
  s.source       = { :git => "https://github.com/AquaSupport/AQSPocketActivity.git", :tag => "v0.1.1" }
  s.source_files  = "AQSPocketActivity/Classes/**/*.{h,m}"
  s.resources = ["AQSPocketActivity/Classes/**/*.png"]
  s.requires_arc = true
  s.platform = "ios", '7.0'

  s.dependency "PocketAPI"
end
