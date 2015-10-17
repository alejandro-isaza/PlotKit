Pod::Spec.new do |s|
  s.name         = "PlotKit"
  s.version      = "0.0.1"
  s.summary      = "OS X plotting framework"

  s.homepage     = "https://github.com/aleph7/PlotKit"
  s.license      = "MIT"
  s.author       = { "Alejandro" => "al@isaza.ca" }
  
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "https://github.com/aleph7/PlotKit.git", :tag => "0.0.1" }
  s.source_files = "PlotKit/*.swift", "PlotKit/**/*.swift"
  
  s.dependency "Upsurge", "~> 0.4"
end
