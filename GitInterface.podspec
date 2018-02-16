Pod::Spec.new do |s|
  s.name         = "GitInterface"
  s.version      = "0.0.2"
  s.summary      = "Git interface"
  s.description  = <<-DESC
     A git interface written in Swift.
  DESC
  s.homepage     = "https://github.com/hectr/swift-git-interface"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Hèctor Marquès" => "h@mrhector.me" }
  s.social_media_url   = "https://twitter.com/elnetus"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/hectr/swift-git-interface.git", :tag => s.version.to_s }
  s.source_files = "Sources/**/*"
  s.frameworks   = "Foundation"
end
