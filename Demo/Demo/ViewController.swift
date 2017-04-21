//
//  ViewController.swift
//  Demo
//
//  Created by MacBook Pro on 2017/4/21.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import UIKit
import SMInstagramPhotoPicker
import Photos

class ViewController: UIViewController, SMPhotoPickerViewControllerDelegate {
    
    var picker: SMPhotoPickerViewController?
    
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         First. It is importance to do this step.
         Be sour your app have Authorization to assecc your photo library.
         
         */
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.picker = SMPhotoPickerViewController()
                self.picker?.delegate = self
            }
        }

    }
    
    
    //show picker. You need use present.
    @IBAction func show(_ sender: UIButton) {
        if picker != nil {
            present(picker!, animated: true, completion: nil)
        }
    }
    
    //No things to show here.
    @IBAction func nothings(_ sender: UIButton) {
        
        let alert = UIAlertController.init(title: "都说啥都没有啦，还点。。。", message: "Do not understan Chinaese? You need google translate.", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "我错了😯", style: .cancel, handler: { (action) in
            
        })
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func didCancelPickingPhoto() {
        print("User cancel picking image")
    }
    
    
    func didFinishPickingPhoto(image: UIImage, meteData: [String : Any]) {
        
        imageView.image = image
    }
}









