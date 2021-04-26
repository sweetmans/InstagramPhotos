//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit
import InstagramPhotosPodspec
import Photos
import PhotosUI

class ViewController: UIViewController {
    var picker: InstagramPhotosPickingViewController?
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
    
    override func viewDidAppear(_ animated: Bool) {
        print(additionalSafeAreaInsets, UIScreen.main.bounds)
    }
    
    private func getPickerReady() {
        let imageProvider = PhotosProvider(viewController: self)
        picker = InstagramPhotosPickingViewController(imagePicking: imageProvider)
    }
    
    //show picker. You need use present.#imageLiteral(resourceName: "simulator_screenshot_C3155FE8-EAC8-4EED-8BA6-4F79A69485BB.png")
    @IBAction func show(_ sender: UIButton) {
        guard let unwrapPicker = picker else { return }
        unwrapPicker.modalPresentationStyle = .fullScreen
        present(unwrapPicker, animated: true, completion: nil)
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
