//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import Foundation

public protocol InstagramPhotosLocalizationsProviding {
    func pinkingControllerNavigationTitle() -> String
    func pinkingControllerNavigationNextButtonText() -> String
    func pinkingControllerDefaultAlbumName() -> String
    func pinkingControllerAddingImageAccessButtonText() -> String
    func albumControllerNavigationTitle() -> String
    func albumControllerNavigationCancelButtonText() -> String
}

public protocol InstagramPhotosLocalizationUpdateable {
    func localizationContents()
}

class InstagramPhotosLocalizationManager {
    var localizationsProviding: InstagramPhotosLocalizationsProviding = InstagramPhotosEnglishLocalizationProvider()
    private var localizationConponents = [InstagramPhotosLocalizationUpdateable]()
    static let main = InstagramPhotosLocalizationManager()
    
    func changeLanguage(provider: InstagramPhotosLocalizationsProviding) {
        self.localizationsProviding = provider
        for component in localizationConponents {
            component.localizationContents()
        }
    }
    
    func addLocalizationConponent(localizationUpdateable: InstagramPhotosLocalizationUpdateable) {
        localizationConponents.append(localizationUpdateable)
    }
}

public struct InstagramPhotosEnglishLocalizationProvider: InstagramPhotosLocalizationsProviding {
    public init() {}
    public func pinkingControllerNavigationTitle() -> String {  return "Select your image" }
    public func pinkingControllerNavigationNextButtonText() -> String { return "Next" }
    public func pinkingControllerDefaultAlbumName() -> String { return "All photos" }
    public func pinkingControllerAddingImageAccessButtonText() -> String { return "Access more photos" }
    public func albumControllerNavigationTitle() -> String { return "Select album" }
    public func albumControllerNavigationCancelButtonText() -> String { return "Cancel" }
}

public struct InstagramPhotosChineseLocalizationProvider: InstagramPhotosLocalizationsProviding {
    public init() {}
    public func pinkingControllerNavigationTitle() -> String {  return "选择照片" }
    public func pinkingControllerNavigationNextButtonText() -> String { return "下一步" }
    public func pinkingControllerDefaultAlbumName() -> String { return "照片图库" }
    public func pinkingControllerAddingImageAccessButtonText() -> String { return "添加可访问照片" }
    public func albumControllerNavigationTitle() -> String { return "选择相册" }
    public func albumControllerNavigationCancelButtonText() -> String { return "取消" }
}
