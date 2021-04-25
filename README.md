<p align="center" >
	<img src="https://github.com/sweetmans/InstagramPhotos/blob/develop/InstagramPhotosPodspec/Assets/banner.png" title="SMInstagramPhotoPicker" float=left>
</p>
<p align="center">
	InstagramPhotos Create By Sweetman, Inc
</p>

[![Version](https://img.shields.io/cocoapods/v/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)

# To be contributed with me
Twitter PM me: [@tubepets](https://twitter.com/tubepets)

New release: 2.0.0
- [x] Rename to InstagramPhotos
- [x] Migrated to Xcode 12
- [x] New UI design same with instagram
- [x] Adding localization support
- [x] Supporting new iOS 14 photos limited access system
## To do
- [ ] Adding filter function
- [ ] Multiples photos select support
### If you like this framework. Please give me a start ⭐️
### Contributor
<p align="left" >
<a href="https://github.com/sweetmans">
	<img src="https://avatars.githubusercontent.com/u/22865790?s=60&v=4" title="ANDY HUANG" float=left>
</a>
</p>

#### Welcome to be one of us.
## Features
- [x] New UI design same with instagram
- [x] Adding localization support
- [x] Supporting new iOS 14 photos limited access system
- [x] So easy to use.
- [x] Support Swift 5.0 and above
- [x] Performances!
- [x] Use GCD and ARC
- [x] Supported iOS 11.0~14.4
## Requirements
- iOS 11.0 or later
- Xcode 12.0 or later
- swift 5.0 or later

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
- [x] Powered by ANDY HUANG on 2021.
- [x] GUANGZHOU CN 510000
- [x] [www.sweetman.cc](https://www.sweetman.cc)
