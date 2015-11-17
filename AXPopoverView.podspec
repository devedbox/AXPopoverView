Pod::Spec.new do |s|
  s.name             = “AXPopoverView”
  s.version          = “0.0.1”
  s.summary          = "A popover view used on iOS."
  s.description      = <<-DESC
                       It is a marquee view used on iOS, which implement by Objective-C.                       DESC
  s.homepage         = "https://github.com/devedbox/AXPopoverView"
  s.license          = 'MIT'
  s.author           = { “艾星” => “862099730@qq.com" }
  s.source           = { :git => "https://github.com/devedbox/AXPopoverView.git", :tag => 0.0.1 }  
  s.platform     = :ios, ‘7.0’
  s.requires_arc = true
  s.source_files = 'AXPopoverView/*'
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'
end