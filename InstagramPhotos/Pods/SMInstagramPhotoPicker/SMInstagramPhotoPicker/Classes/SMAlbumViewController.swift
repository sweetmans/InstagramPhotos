//
//  SMAlbumViewController.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/21.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import UIKit

class SMAlbumViewController: UIViewController {
    let albumView = SMPhotoPickerAlbumView.instance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(albumView)
        navigationItem.title = "All Albums"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        albumView.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        albumView.tableView.reloadData()
    }
    
}
