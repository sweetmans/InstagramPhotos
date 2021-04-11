//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit
import SMInstagramPhotoPicker
import Photos

class ViewController: UIViewController {
    var picker: SMPhotoPickerViewController?
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.getPickerReady()
                }
            }
        }
    }
    
    private func getPickerReady() {
        picker = SMPhotoPickerViewController()
        picker?.delegate = self
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
}

extension ViewController: SMPhotoPickerViewControllerDelegate {
    func didCancelPickingPhoto() {
        print("User cancel picking image")
    }
    
    func didFinishPickingPhoto(image: UIImage, meteData: [String : Any]) {
        imageView.image = image
    }
}
