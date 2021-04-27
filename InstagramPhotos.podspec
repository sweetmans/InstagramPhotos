#
# Be sure to run `pod lib lint InstagramPhotos.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'InstagramPhotos'
  s.version          = '2.0.1'
  s.summary          = 'An instagram design photos picker viewController using swift'
  s.license         = 'MIT'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A instagram photos picker ViewController using swift 5. Your can easy to get your photo quickly.
And zooming, clip.
New UI design same with instagram
Adding localization support
Supporting new iOS 14 photos limited access system
                       DESC

  s.homepage         = 'https://cocoapods.org/pods/InstagramPhotos'
  s.screenshots      = 'https://github.com/sweetmans/InstagramPhotos/blob/develop/Assets/banner.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sweetmans' => 'developer@sweetman.cc' }
  s.source           = { :git => 'https://github.com/sweetmans/InstagramPhotos.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tubepets'

  s.ios.deployment_target = '11.0'
  s.source_files = 'InstagramPhotos/InstagramPhotosPodspec/Classes/**/*.swift'
  s.resources    = ['InstagramPhotos/InstagramPhotosPodspec/Resources/*.png', 'InstagramPhotos/InstagramPhotosPodspec/Resources/*.xib']
  s.module_name  = 'InstagramPhotos'
  # s.resource_bundles = {
  #   'SMColor' => ['SMColor/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks  = 'UIKit', 'Photos', 'PhotosUI'
  s.swift_versions = ['5.0', '5.0.1', '5.1', '5.1.2', '5.1.3', '5.2', '5.2.2', '5.2.4', '5.3', '5.3.1', '5.3.2']
  # s.dependency 'AFNetworking', '~> 2.3'
end
