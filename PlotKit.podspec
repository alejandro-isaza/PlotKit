Pod::Spec.new do |s|
  s.name         = "PlotKit"
  s.version      = "0.0.2"
  s.summary      = "OS X plotting framework"

  s.homepage     = "https://github.com/aleph7/PlotKit"
  s.license      = "MIT"
  s.author       = { "Alejandro" => "al@isaza.ca" }
  
  s.osx.deployment_target = "10.10"

  s.source       = { git: "https://github.com/aleph7/PlotKit.git", tag: s.version }
  s.source_files = "PlotKit/*.swift", "PlotKit/**/*.swift"
end
