//
//  UIViewController+Extension.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/20.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import Foundation
import UIKit


enum SMSreenSize {
    case iphone
    case ipad
}


extension UIViewController {
    
    func getScreenSize() -> SMSreenSize{
        
        //iPad
        if self.traitCollection.horizontalSizeClass == .regular &&  self.traitCollection.verticalSizeClass == .regular {
            return .ipad
        }else{
            return .iphone
        }
    }
    
}








