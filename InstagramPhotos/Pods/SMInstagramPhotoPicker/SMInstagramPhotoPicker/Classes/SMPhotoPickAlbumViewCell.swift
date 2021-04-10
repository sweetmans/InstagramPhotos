//
//  SMPhotoPickAlbumViewCell.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/19.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import UIKit

class SMPhotoPickAlbumViewCell: UITableViewCell {

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var model: AlbumModel? {didSet{updateAlbumInfo()}}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        logoView.layer.cornerRadius = 3.0
        logoView.layer.borderWidth = 0.33
        logoView.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateAlbumInfo() {
        
        model?.fetchFirstImage(returnImage: { (image) in
            self.logoView.image = image
        })
        nameLabel.text = model?.name
        countLabel.text = "\(String(describing: model!.count)) photos"
    }
    
}
