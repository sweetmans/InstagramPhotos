//
//  Copyright © 2021年 Sweetman, Inc. All rights reserved.
//

import UIKit

class SMProgressView: UIView {
    var progress: CGFloat = 0.0 {didSet{updateProgress()}}
    var progressLayer: CAShapeLayer = CAShapeLayer()
    
    override func awakeFromNib() {
        progressLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0
        progressLayer.fillColor = UIColor(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 0.56).cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        progressLayer.path = UIBezierPath(roundedRect: progressLayer.frame, cornerRadius: 30).cgPath
        self.layer.addSublayer(progressLayer)
    }
    
    func updateProgress() {
        if progress < 0.09 {
            progress = 0.09
        }
        progressLayer.strokeEnd = progress
    }
}
