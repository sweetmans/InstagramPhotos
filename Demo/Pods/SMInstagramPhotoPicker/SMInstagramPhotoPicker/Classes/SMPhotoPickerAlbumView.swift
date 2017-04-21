//
//  SMPhotoPickerAlbumView.swift
//  SMInstagramPhotosPicker
//
//  Created by MacBook Pro on 2017/4/19.
//  Copyright © 2017年 Sweetman, Inc. All rights reserved.
//

import UIKit


protocol SMPhotoPickerAlbumViewDelegate {

    func didSeletctAlbum(album: AlbumModel)
    
}

class SMPhotoPickerAlbumView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let albums: [AlbumModel] = AlbumModel.listAlbums()
    
    var delegate: SMPhotoPickerAlbumViewDelegate? = nil
    
    static func instance() -> SMPhotoPickerAlbumView {
        
        let view = UINib(nibName: "SMPhotoPickerAlbumView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! SMPhotoPickerAlbumView
        view.initialize()
        return view
    }
    
    
    func initialize() {
        
        tableView.register(UINib(nibName: "SMPhotoPickAlbumViewCell", bundle: Bundle(for: self.classForCoder)), forCellReuseIdentifier: "SMPhotoPickerAlbumView")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "SMPhotoPickerAlbumView", for: indexPath) as! SMPhotoPickAlbumViewCell
        cell.model = albums[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return albums.count > 0 ? albums.count : 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.didSeletctAlbum(album: albums[indexPath.row])
        
    }
    
}










