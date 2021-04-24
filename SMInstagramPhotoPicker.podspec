#
# Be sure to run `pod lib lint SMColor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SMInstagramPhotoPicker'
  s.version          = '0.3.8'
  s.summary          = 'SMInstagramPhotoPicker, A instagram photos picker viewcontroller using swift 3.1.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A instagram photos picker viewcontroller using swift 3.1. Your can easy to get your photo quickly.
And zooming, clip.
A beautiful design UI.
A Performances framework.
A iOS 10.0 or later.
                       DESC

  s.homepage         = 'https://github.com/sweetmans/SMInstagramPhotoPicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sweetmans' => 'developer@sweetman.cc' }
  s.source           = { :git => 'https://github.com/sweetmans/SMInstagramPhotoPicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'SMInstagramPhotoPicker/Classes/**/*.swift'
  s.resources = ['SMInstagramPhotoPicker/Resources/*.png', 'SMInstagramPhotoPicker/Resources/*.xib']
  s.module_name = 'SMInstagramPhotoPicker'
  # s.resource_bundles = {
  #   'SMColor' => ['SMColor/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Photos', 'PhotosUI'
  # s.dependency 'AFNetworking', '~> 2.3'
end
