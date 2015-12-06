//
//  VVImageCollectionView.swift
//  Nian iOS
//
//  Created by WebosterBob on 12/6/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class VVImageCollectionView: UICollectionView {

    typealias DownloadedSingleImage = (image: UIImage, url: NSURL?) -> Void
    typealias ImageSelectedHandler = (path: String, indexPath: NSIndexPath) -> Void
    
    let placeholderImage = UIImage(named: "drop")

    var imageSelectedHandler: ImageSelectedHandler?
    var imagesDataSource = NSMutableArray()
    var sid: String = ""
    
    var containImages: [UIImage] = []
    
    private var _imagesBaseURL = NSURL(string: "http://img.nian.so/step/")!
    
    var imagesBaseURL: NSURL {
        set(newValue) {
            self._imagesBaseURL = newValue
        }
        
        get {
            return self._imagesBaseURL
        }
        
    }

    let sd_manager = SDWebImageManager.sharedManager()
    
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        
        self.registerClass(VVImageViewCell.self, forCellWithReuseIdentifier: "VVImageViewCell")
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    func setImage() {
        self.downloadImages(self.imagesDataSource, callback: { (image, url) -> Void in
            self.containImages.append(image)
            
            if let _url = url {
                let _string = _url.absoluteString
                let _arr = _string.characters.split{ $0 == "/" }.map(String.init)
                
                for (var tmp = 0; tmp < self.imagesDataSource.count; tmp++) {
                    if ((self.imagesDataSource[tmp] as! NSDictionary)["path"] as! String) == _arr.last! {
                        self.reloadItemsAtIndexPaths([NSIndexPath(forRow: tmp, inSection: 0)])
                    }
                }
            }
        })
    }
    

    func downloadImages(urls: NSArray, callback: DownloadedSingleImage) {
        for (var tmp = 0; tmp < urls.count; tmp++) {
            let dict = self.imagesDataSource[tmp] as! NSDictionary
            let _imageURLString = dict["path"] as! String
            let _imageURL = NSURL(string: _imageURLString, relativeToURL: self._imagesBaseURL)!
            
            sd_manager.downloadImageWithURL(_imageURL,
                options: SDWebImageOptions(rawValue: 0),
                progress: { (receivedSize, expectedSize) -> Void in
                    
                }, completed: { (image, error, cacheType, finished, imageURL) -> Void in
                    if let _ = error {
                        callback(image: self.placeholderImage!, url: NSURL())
                    } else {
                        callback(image: image, url: imageURL)
                    }
            })
        }
        
    }
    
    
    func cancelImageRequestOperation() {
        self.sd_manager.cancelAll()
        self.containImages.removeAll(keepCapacity: false)
        
        self.reloadData()
    }
    
}


extension VVImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesDataSource.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VVImageViewCell", forIndexPath: indexPath) as! VVImageViewCell
        
        if indexPath.row < self.containImages.count {
            cell.imageView.image = self.containImages[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        imageSelectedHandler!(path: (self.imagesDataSource[indexPath.row] as! NSDictionary)["path"] as! String, indexPath: indexPath)
    }
    
}




class VVImageViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        
        constrain(self.imageView) { imageView in
            imageView.top    == imageView.superview!.top
            imageView.bottom == imageView.superview!.bottom
            imageView.left   == imageView.superview!.left
            imageView.right  == imageView.superview!.right
        }
        
        self.imageView.contentMode = .ScaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}










































