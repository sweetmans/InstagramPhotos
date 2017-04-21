<p align="center" >
	<img src="https://github.com/sweetmans/SMColor/blob/master/SMColor/Assets/swcolor.png" title="SWColor" float=left>
</p>
<p align="center">
	SMInstagramPhotoPicker Create By Sweetman, Inc
</p>

[![Version](https://img.shields.io/cocoapods/v/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/SMInstagramPhotoPicker.svg?style=flat)](http://cocoapods.org/pods/SMInstagramPhotoPicker)
<<<<<<< HEAD

## If you like this framework. Please give me a start.
=======
>>>>>>> 0.3.8

## If you like this framework. Please give me a start.

## Features

- [x] Same design as Instagram and animation.
- [x] So easy to use.
- [x] Support Swift 3.1
- [x] Performances!
- [x] Use GCD and ARC

## Requirements

- iOS 10.3 or later
- Xcode 8.3 or later
<<<<<<< HEAD
- swift 3.1
=======

>>>>>>> 0.3.8
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

<<<<<<< HEAD
In your controller.
```swift
var picker: SMPhotoPickerViewController?
```
- [x] First. It is importance to do this step.
- [x] Be sour your app have Authorization to assecc your photo library.

- [x] on your plist.info add one attrabute.
=======
Int your controller.
```swift
var picker: SMPhotoPickerViewController?
```
First. It is importance to do this step.
Be sour your app have Authorization to assecc your photo library.

on your plist.info add one attrabute.
>>>>>>> 0.3.8

```ruby
kye: Privacy - Photo Library Usage Description
String: Your app need assecc your photo library.
```
<<<<<<< HEAD
- [x] And then request Authorization.
=======
And then request Authorization.
>>>>>>> 0.3.8

```swift
PHPhotoLibrary.requestAuthorization { (status) in
if status == .authorized {
	self.picker = SMPhotoPickerViewController()
		self.picker?.delegate = self
	}
}
```

<<<<<<< HEAD
- [x] Show!!!
=======
Show!!!
>>>>>>> 0.3.8
```swift
//show picker. You need use present.
@IBAction func show(_ sender: UIButton) {
    if picker != nil {
        present(picker!, animated: true, completion: nil)
    }
}
```

<<<<<<< HEAD
- [x] Get your image through deledate.
=======
Get your image through deledate.
>>>>>>> 0.3.8
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


## Author

- [x] Created by Sweetman, Inc on 2017.
- [x] GuangZhou City. CN 510000 
- [x] [https://www.sweetman.cc](https://www.sweetman.cc)
