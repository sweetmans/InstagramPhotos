<p align="center" >
	<img src="https://github.com/sweetmans/InstagramPhotos/blob/develop/Assets/banner.png" title="SMInstagramPhotoPicker" float=left>
</p>

[![Version](https://img.shields.io/cocoapods/v/InstagramPhotos.svg?style=for-the-badge&logo=appveyort)](http://cocoapods.org/pods/InstagramPhotos)
[![License](https://img.shields.io/cocoapods/l/InstagramPhotos.svg?style=for-the-badge&logo=appveyor)](http://cocoapods.org/pods/InstagramPhotos)
[![Platform](https://img.shields.io/cocoapods/p/InstagramPhotos.svg?style=for-the-badge&logo=appveyor)](http://cocoapods.org/pods/InstagramPhotos)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg?style=for-the-badge&logo=appveyor)](https://houndci.com)

## To be contributed with me
#### Twitter PM me [![Twitter](https://img.shields.io/twitter/url?label=tubepets&style=social&url=https%3A%2F%2Ftwitter.com%2Ftubepets)](https://twitter.com/tubepets)

## The latest `MAJOR` release: `2.0.0` [RELEASENOTE.md](https://github.com/sweetmans/InstagramPhotos/blob/develop/RELEASENOTE.md)
- [x] Rename to InstagramPhotos
- [x] Migrated to Xcode 12
- [x] New UI design same with instagram
- [x] Adding localization support
- [x] Supporting new iOS 14 photos limited access system

## The latest release `2.0.1` `CURRENT` [RELEASENOTE.md](https://github.com/sweetmans/InstagramPhotos/blob/develop/RELEASENOTE.md)
- [x] Use InstagramPhotos folder for cocoapods source [SMIIP-11](https://sweetmancc.atlassian.net/browse/SMIIP-11)
- [x] Handle iPhone safe area for none all display iPhones [SMIIP-7](https://sweetmancc.atlassian.net/browse/SMIIP-7)
- [x] Release 2.0.1 [SMIIP-13](https://sweetmancc.atlassian.net/browse/SMIIP-13)

## TO DO
- [ ] Adding SwiftPackage support [SMIIP-12](https://sweetmancc.atlassian.net/browse/SMIIP-12)  
- [ ] Adding filter function [SMIIP-9](https://sweetmancc.atlassian.net/browse/SMIIP-9)
- [ ] Multiples photos select support [SMIIP-10](https://sweetmancc.atlassian.net/browse/SMIIP-10)
- [ ] Create iOS code checking [SMIIP-3](https://sweetmancc.atlassian.net/browse/SMIIP-3)
- [ ] New design for iPad support [SMIIP-8](https://sweetmancc.atlassian.net/browse/SMIIP-8)

### If you like this framework. Please give me a star ⭐️
### Contributor
<p align="left" >
<a href="https://github.com/sweetmans">
	<img src="https://avatars.githubusercontent.com/u/22865790?s=60&v=4" title="ANDY HUANG" float=left>
</a>
</p>

### Welcome to be one of us 🧑🏻‍💻🧑‍💻🧑🏼‍💻🧑🏽‍💻🧑🏾‍💻🧑🏿‍💻

## Features
- [x] New UI design same with instagram
- [x] Adding localization support
- [x] Supporting new iOS 14 photos limited access system
- [x] So easy to use.
- [x] Support Swift 5.0 and above
- [x] Performances!
- [x] Use GCD and ARC
- [x] Supported iOS 11.0 and above
## Requirements
- iOS 11.0 or above
- Xcode 12.0 or above
- swift 5.0 or above

## Getting Started

### Installation

SMInstagramPhotoPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'InstagramPhotos'
```
```swift
import InstagramPhotos
```

### Usage

- In your controller.
```swift
var picker: InstagramPhotosPickingViewController?
```
#### Photo library access
First. It is importance to do this step.
Be sour your app have Authorization to access your photo library.
on your `plist.info` adding this attribute
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Your app need access your photo library</string>
```
if `iOS 14` you need to set `PHPhotoLibraryPreventAutomaticLimitedAccessAlert` to `YES` on `plist.info` to prevent limited photos access alert.
```xml
<key>PHPhotoLibraryPreventAutomaticLimitedAccessAlert</key>
<true/>
```
#### Initialize your photo Pinking View Controller
```swift
private func getPickerReady() {
    let imageProvider = PhotosProvider(viewController: self)
    picker = InstagramPhotosPickingViewController(imagePicking: imageProvider,
                                         ocalizationsProviding: InstagramPhotosChineseLocalizationProvider())
}
```
#### Present the pickingViewController
```swift
@IBAction func show(_ sender: UIButton) {
    guard let unwrapPicker = picker else { return }
    unwrapPicker.modalPresentationStyle = .fullScreen
    present(unwrapPicker, animated: true, completion: nil)
}
```

#### Get your image through `InstagramPhotosPicking` delegate.

```swift
extension ViewController: InstagramPhotosPicking {
    //your viewcontroller
    func instagramPhotosDidFinishPickingImage(result: InstagramPhotosPickingResult) {
        switch result {
        case .failure(let error):
            switch error {
            case .cancelByUser:
                print("User canceled selete image")
            default:
                print(error)
            }
        case .success(let ipImage):
            viewController.imageView.image = ipImage.image
        }
    }
}
```

#### Customize Localization
You could use default `InstagramPhotosChineseLocalizationProvider()` for `English`, `InstagramPhotosEnglishLocalizationProvider()` for `Chinese`.

define you own localization provider
```swift
// Exsample Korean
struct KoreanLocalizationProvider: InstagramPhotosLocalizationsProviding {
    public init() {}
    public func pinkingControllerNavigationTitle() -> String {  return "사진 선택" }
    public func pinkingControllerNavigationNextButtonText() -> String { return "다음 단계" }
    public func pinkingControllerDefaultAlbumName() -> String { return "사진 갤러리" }
    public func pinkingControllerAddingImageAccessButtonText() -> String { return "접근 가능한 사진 추가" }
    public func albumControllerNavigationTitle() -> String { return "앨범 선택" }
    public func albumControllerNavigationCancelButtonText() -> String { return "취소" }
    public func photosLimitedAccessModeText() -> String { return "액세스 권한이있는 모든 사진이 표시됩니다" }
}
```
Apply it in the pickingViewController Initialize
```swift
private func getPickerReady() {
    let imageProvider = PhotosProvider(viewController: self)
    picker = InstagramPhotosPickingViewController(imagePicking: imageProvider,
                                        localizationsProviding: KoreanLocalizationProvider())
}
```

## Licenses

All source code is licensed under the [MIT License](https://raw.github.com/rs/SDWebImage/master/LICENSE).

## About
- [x] Powered by SWEETMAN,INC on 2021
- [x] GUANGZHOU CN 510000
- [x] [www.sweetman.cc](https://www.sweetman.cc)
