<p align="center" >
	<img src="https://github.com/sweetmans/SMInstagramPhotoPicker/blob/master/SMInstagramPhotoPicker/Assets/banner.png" title="SMInstagramPhotoPicker" float=left>
</p>
<p align="center">
	SMInstagramPhotoPicker Create By Sweetman, Inc
</p>

[![Version](https://img.shields.io/cocoapods/v/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)

# To be contributed with me
Twitter PM me: [@tubepets](https://twitter.com/tubepets)

Next release: 2.0.0 on the way.
- [x] Rename to InstagramPhotos
- [x] Migrated to Xcode 12
- [x] Adding Unit test and UI test
- [x] Workflow checking
## To do
- [ ] New design to match Instagram.
- [ ] Handle Apple New options photo library access system
- [ ] Adding filter function
- [ ] Multiples photos select support
### If you like this framework. Please give me a start.
### Contributor
Welcome to be one of us.
## Features
- [x] Same design as Instagram and animation.
- [x] So easy to use.
- [x] Support Swift 5.0 and above
- [x] Performances!
- [x] Use GCD and ARC

## Requirements

- iOS 12.0 or later
- Xcode 12.0 or later
- swift 5.0 or later

## Getting Started

### Installation

SMInstagramPhotoPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SMInstagramPhotoPicker"
```
```swift
import SMInstagramPhotoPicker
```

### Use


- In your controller.
```swift
var picker: SMPhotoPickerViewController?
```
- [x] First. It is importance to do this step.
- [x] Be sour your app have Authorization to assecc your photo library.

- on your plist.info add one attrabute.

```ruby
kye: Privacy - Photo Library Usage Description
String: Your app need assecc your photo library.
```
- And then request Authorization.

```swift
PHPhotoLibrary.requestAuthorization { (status) in
if status == .authorized {
	self.picker = SMPhotoPickerViewController()
		self.picker?.delegate = self
	}
}
```

- Show!!!

```swift
//show picker. You need use present.
@IBAction func show(_ sender: UIButton) {
    if picker != nil {
        present(picker!, animated: true, completion: nil)
    }
}
```

- Get your image through deledate.

```swift
class ViewController: UIViewController, SMPhotoPickerViewControllerDelegate {
	//your viewcontroller

    func didCancelPickingPhoto() {
        print("User cancel picking image")
    }
    
    
    func didFinishPickingPhoto(image: UIImage, meteData: [String : Any]) {
        
        imageView.image = image
    }
}
```

## Licenses

All source code is licensed under the [MIT License](https://raw.github.com/rs/SDWebImage/master/LICENSE).

## Copyright
- [x] Created by Sweetman, Inc on 2017.
- [x] GuangZhou City. CN 510000 
- [x] [https://www.sweetman.cc](https://www.sweetman.cc)