Pod::Spec.new do |s|
  s.name         = "GCPrePermission"
  s.version      = "0.0.2"
  s.summary      = "A albums, system cameras, microphones, positioning, calendar, reminders ate authorized tool of GCPrePermission."
  s.homepage     = "https://github.com/XiaoHanGe/GCPrePermissions"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "韩俊强" => "532167805@qq.com" }
  s.authors            = { "韩俊强" => "532167805@qq.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/XiaoHanGe/GCPrePermissions.git", :tag => s.version.to_s}
  s.source_files  = "GCPrePermission/**/*.{h,m}"
  s.public_header_files = "GCPrePermission/**/*.h"
  s.frameworks = "CoreGraphics", "AssetsLibrary", "EventKit", "CoreLocation", "AddressBook", "AVFoundation"
  s.requires_arc = true
end
