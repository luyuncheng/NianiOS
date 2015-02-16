//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

protocol CircleTagDelegate {
    func onTagSelected(tag: String, tagType: Int, dreamType: Int)
}
protocol DreamPromoDelegate {
    func onPromoClick(id: Int, content: String)
}

class CircleTagViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var circleTagDelegate: CircleTagDelegate?
    var dreamPromoDelegate: DreamPromoDelegate?
    var dataArray = NSMutableArray()
    
    let imgArray = ["daily", "camera", "love", "startup", "read", "us", "draw", "english", "collection", "fit", "music", "write", "travel", "food", "design", "thegame", "work", "habit", "handwriting", "others"]
    
    override func viewDidLoad() {
        setupViews()
        SAReloadData()
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.viewBack()
        self.view.addSubview(navView)
        self.view.backgroundColor = UIColor.whiteColor()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.contentInset.bottom = 60
        self.extendedLayoutIncludesOpaqueBars = true
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        if dreamPromoDelegate != nil {
            titleLabel.text = "推广梦想"
        }else{
            titleLabel.text = "选择标签"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("TagMediaCell", forIndexPath: indexPath) as TagMediaCell
        var data = self.dataArray[index] as NSDictionary
        var title = data.objectForKey("title") as String
        var img = data.objectForKey("img") as String
        mediaCell.label.text = "\(title)"
        mediaCell.imageView.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!) {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        if dreamPromoDelegate != nil {  // 如果是推广梦想
            var id = data.stringAttributeForKey("id")
            var title = data.stringAttributeForKey("title")
            if let v = id.toInt() {
                dreamPromoDelegate?.onPromoClick(v, content: title)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else if circleTagDelegate != nil { // 如果是梦境绑定标签
            var tag = (data.objectForKey("hashtag") as String).toInt()
            var dreamType = (data.objectForKey("id") as String).toInt()
            var textTag = "未选标签"
            if tag != nil {
                if tag >= 1 {
                    textTag = V.Tags[tag!-1]
                }
            }else{
                tag = 0
            }
            circleTagDelegate?.onTagSelected(textTag, tagType: tag!, dreamType: dreamType!)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func SAReloadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var url = "http://nian.so/api/circle_tag.php?uid=\(safeuid)"
        if dreamPromoDelegate != nil {
            url = "http://nian.so/api/addstep_dream.php?uid=\(safeuid)&shell=\(safeshell)"
        }
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull() {
                var arr = data["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                if self.dataArray.count == 0 {
                    var textEmpty = "要先有一个\n公开中的梦想"
                    if self.dreamPromoDelegate == nil {
                        textEmpty = "你的梦想\n都没有标签"
                    }
                    var viewTop = viewEmpty(globalWidth, content: textEmpty)
                    viewTop.setY(104)
                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    viewHolder.addSubview(viewTop)
                    self.view.addSubview(viewHolder)
                    self.collectionView?.hidden = true
                }
                self.collectionView.reloadData()
            }
        })
    }
}
