Pod::Spec.new do |s|
  s.name         = "GCPrePermission"
  s.version      = "0.0.1"
  s.summary      = "A short description of GCPrePermission."
  s.homepage     = "https://github.com/XiaoHanGe/GCPrePermissions"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "韩俊强" => "532167805@qq.com" }
  s.authors            = { "韩俊强" => "532167805@qq.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/XiaoHanGe/GCPrePermissions.git", :tag => s.version }

  s.source_files  = "GCPerPermissions/**/*.{h,m}"
  s.public_header_files = "Classes/**/*.h"
  s.frameworks = "SomeFramework", "AnotherFramework"
  s.library   = "iconv"
  s.requires_arc = true

  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "JSONKit", "~> 1.4"
end
