//
//  UIImage+Extension.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/20.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    func crop(rect: CGRect, scale: CGFloat) -> UIImage {
        
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale
        
        rect.origin.x *= scale
        rect.origin.y *= scale
        rect.size.height *= scale
        rect.size.width *= scale
        //print(rect)
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
