
Pod::Spec.new do |s|

s.name         = "AXPopoverView"
s.version      = "0.6.3"
s.summary      = "`AXPopoverView` is an iOS customizable view that displays a bubble style view."

s.description  = <<-DESC
               `AXPopoverView` is an iOS customizable view that displays a bubble style view with a custom view when some messages need to show from a target view or a target rect. `AXPopoverView` contains how to use custom view to customize the popover view. The popover view (mostly used as `Label` or `Other`) is a convenient and hommization way for developer to use.
               DESC
s.homepage     = "https://github.com/devedbox/AXPopoverView"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
s.author             = { "艾星" => "862099730@qq.com" }
  # Or just: s.author    = "aiXing"
  # s.authors            = { "aiXing" => "862099730@qq.com" }
  # s.social_media_url   = "http://twitter.com/aiXing"
  # s.platform     = :ios
s.platform     = :ios, "7.0"
  # s.ios.deployment_target = “7.0”
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
s.source       = { :git => "https://github.com/devedbox/AXPopoverView.git", :tag => s.version }
s.source_files  = "AXPopoverView/AXPopoverView/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"
  # s.public_header_files = "Classes/**/*.h"
s.resource  = "AXPopoverView/AXPopoverView/AXPopoverView.bundle"
  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # s.framework  = "SomeFramework"
s.frameworks = "UIKit", "Foundation"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
s.requires_arc = true
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
s.dependency 'AGGeometryKit+POP'
s.dependency 'AXAttributedLabel'
s.dependency 'pop', '~> 1.0.4'
s.dependency 'AGGeometryKit', '~> 1.0'

end
