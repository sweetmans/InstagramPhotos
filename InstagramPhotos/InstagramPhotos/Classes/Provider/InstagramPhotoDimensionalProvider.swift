//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit
import Foundation

public protocol InstagramPhotoDimensionalProviding {
    func safeAreaInsets() -> UIEdgeInsets
    func pickingControllerNavigationViewHeight() -> CGFloat
    func libraryActionViewheight() -> CGFloat
    func standerDevideScaleRatial() -> Double
}

public struct InstagramPhotoDimensionalProvider: InstagramPhotoDimensionalProviding  {
    private let width = UIScreen.main.bounds.width
    private let standerDeviceWidth = 428.0
    
    public func safeAreaInsets()  -> UIEdgeInsets {
        guard let insets =  UIApplication.shared.keyWindow?.safeAreaInsets else { return UIEdgeInsets.zero}
        return insets
    }
    
    public func pickingControllerNavigationViewHeight() -> CGFloat {
        return 44.0
    }
    
    public func libraryActionViewheight() -> CGFloat {
        let hight = CGFloat(58.0 * standerDevideScaleRatial())
        return  hight > 58.0 ? 58.0 : hight
    }
    
    public func standerDevideScaleRatial() -> Double {
        return Double(width) / standerDeviceWidth
    }
}
