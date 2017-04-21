//
//  ViewController.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/18.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import UIKit
import Photos
import SMInstagramPhotoPicker

class ViewController: UIViewController, SMPhotoPickerViewControllerDelegate {
    func didCancelPickingPhoto() {
        print("User cancel picking photo")
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    let pick = SMPhotoPickerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pick.delegate = self
        
        PHPhotoLibrary.requestAuthorization { (status) in
            
        }
        
    }
    
    func didFinishPickingPhoto(image: UIImage, meteData: [String : Any]) {
        imageView.image = image
        //print(meteData)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Show(_ sender: UIButton) {
        print(self.getScreenSize())
        
        if self.getScreenSize() == .ipad{
            
            let album = SMAlbumViewController()
            let nav = UINavigationController(rootViewController: album)
            nav.navigationBar.isTranslucent = false
            
            album.albumView.delegate = self.pick
            let split = UISplitViewController()
            split.viewControllers = [nav, self.pick]
            
            
            split.preferredDisplayMode = .allVisible
            split.preferredPrimaryColumnWidthFraction = 375.0 / UIScreen.main.bounds.width
            
            self.showDetailViewController(split, sender: nil)
        }else{
            
            present(pick, animated: true) {
                
            }
        }
    }
    @IBAction func nothings(_ sender: UIButton) {
        
        let alert = UIAlertController.init(title: "都说啥都没有啦，还点。。。", message: "Do not understan Chinaese? You need google translate.", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "我错了😯", style: .cancel, handler: { (action) in
            
        })
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

