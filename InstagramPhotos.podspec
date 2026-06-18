#
# Be sure to run `pod lib lint InstagramPhotos.podspec` to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'InstagramPhotos'
  s.version          = '3.0.0'
  s.summary          = 'A SwiftUI photo picker with Instagram-style album browsing, preview, and iCloud support'
  s.license          = 'MIT'
  s.description      = <<-DESC
A modern SwiftUI photo picker for Apple Photos with album browsing, zoomable preview,
single/multiple selection, limited-access handling, and iCloud download progress.
                       DESC

  s.homepage         = 'https://github.com/sweetmans/InstagramPhotos'
  s.screenshots      = 'https://github.com/sweetmans/InstagramPhotos/blob/develop/Assets/banner.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sweetmans' => 'bp@sweetman.cc' }
  s.source           = { :git => 'https://github.com/sweetmans/InstagramPhotos.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tubepets'

  s.ios.deployment_target = '16.0'
  s.source_files = 'Sources/InstagramPhotos/**/*.swift'
  s.module_name  = 'InstagramPhotos'
  s.frameworks   = 'Photos', 'PhotosUI', 'UIKit'
  s.swift_versions = ['5.9']
end