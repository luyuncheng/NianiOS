//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class UserViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, AddstepDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate{
    
    let identifier = "user"
    let identifier2 = "usertop"
    let identifier3 = "step"
    var lefttableView:UITableView?
    var righttableView:UITableView?
    var dataArray = NSMutableArray()
    var dataArray2 = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var deleteSheet:UIActionSheet?
    var userMoreSheet:UIActionSheet!
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath
    
    var EditId:Int = 0
    var EditContent:String = ""
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ShareContent", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DreamimageViewTapped", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "userIsFo", object:nil)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ShareContent:", name: "ShareContent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "DreamimageViewTapped:", name: "DreamimageViewTapped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userIsFo:", name: "userIsFo", object: nil)
    }
    
    func userIsFo(noti:NSNotification){
        var content:NSString = noti.object! as NSString
        if content == "0" {
            setupFoButton()
        }else if content == "1" {
            setupUnfoButton()
        }
    }
    
    func ShareContent(noti:NSNotification){
        var content:AnyObject = noti.object!
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(Id)")!
        var customActivity = SAActivity()
        customActivity.saActivityTitle = "举报"
        customActivity.saActivityImage = UIImage(named: "flag")!
        customActivity.saActivityFunction = {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)", "http://nian.so/api/a.php")
                if(sa == "1"){
                    dispatch_async(dispatch_get_main_queue(), {
                        UIView.showAlertView("谢谢", message: "如果这个进展不合适，我们会将其移除。")
                    })
                }
            })
        }
        if content[1] as NSString != "" {
            var theimgurl:String = content[1] as String
            var imgurl = NSURL(string: theimgurl)
            var cacheFilename = imgurl!.lastPathComponent
            var cachePath = FileUtility.cachePath(cacheFilename)
            var image:AnyObject = FileUtility.imageDataFromPath(cachePath)
            let activityViewController = UIActivityViewController(
                activityItems: [ content[0], url, image ],
                applicationActivities: [ customActivity ])
            activityViewController.excludedActivityTypes = [
                UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
            ]
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }else{
            let activityViewController = UIActivityViewController(
                activityItems: [ content[0], url ],
                applicationActivities: [ customActivity ])
            activityViewController.excludedActivityTypes = [
                UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
            ]
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    func setupViews()
    {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.lefttableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.lefttableView!.delegate = self;
        self.lefttableView!.dataSource = self;
        self.lefttableView!.backgroundColor = BGColor
        self.lefttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.righttableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.righttableView!.delegate = self;
        self.righttableView!.dataSource = self;
        self.righttableView!.backgroundColor = BGColor
        self.righttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.righttableView!.hidden = true
        var nib = UINib(nibName:"UserCell", bundle: nil)
        var nib2 = UINib(nibName:"UserCellTop", bundle: nil)
        var nib3 = UINib(nibName:"StepCell", bundle: nil)
        
        
        self.title = "梦想"
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.lefttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.righttableView?.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.righttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.lefttableView!)
        self.view.addSubview(self.righttableView!)
        
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        //关注按钮
        
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
    }
    
    func setupFoButton(){
        var spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)
        spaceButton.width = -12
        var rightButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        rightButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAfo"))
        var imageView = UIImageView(frame: CGRectMake(12, 6, 16, 20))
        imageView.image = UIImage(named: "fo")
        rightButtonView.addSubview(imageView)
        var rightButton = UIBarButtonItem(customView: rightButtonView)
        var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "userMore")
        moreButton.image = UIImage(named:"more")
        self.navigationItem.rightBarButtonItems = [ spaceButton, rightButton, moreButton ]
    }
    
    func setupUnfoButton(){
        var spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)
        spaceButton.width = -12
        var rightButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        rightButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAunfo"))
        var imageView = UIImageView(frame: CGRectMake(12, 6, 16.5, 20))
        imageView.image = UIImage(named: "unfo")
        rightButtonView.addSubview(imageView)
        var rightButton = UIBarButtonItem(customView: rightButtonView)
        var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "userMore")
        moreButton.image = UIImage(named:"more")
        self.navigationItem.rightBarButtonItems = [ spaceButton, rightButton, moreButton ]
    }
    
    func SAfo(){
        setupUnfoButton()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)&&fo=1", "http://nian.so/api/fo.php")
            if sa != "" && sa != "err" {
            }
        })
    }
    
    func SAunfo(){
        setupFoButton()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)&&unfo=1", "http://nian.so/api/fo.php")
            if sa != "" && sa != "err" {
            }
        })
    }
    
    func userMore(){
        self.userMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.userMoreSheet.addButtonWithTitle("拖进小黑屋")
        self.userMoreSheet.addButtonWithTitle("取消")
        self.userMoreSheet.cancelButtonIndex = 1
        self.userMoreSheet.showInView(self.view)
    }
    
    func loadData()
    {
        var url = urlString()
        // self.refreshView!.startLoading()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull()
            {
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
            }
            self.lefttableView!.reloadData()
            self.lefttableView!.footerEndRefreshing()
            self.page++
        })
    }
    func RightloadData()
    {
        var url = "http://nian.so/api/user_dream.php?page=\(page)&uid=\(Id)"
        // self.refreshView!.startLoading()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull()
            {
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            
            for data : AnyObject  in arr
            {
                self.dataArray2.addObject(data)
            }
            self.righttableView!.reloadData()
            self.righttableView!.footerEndRefreshing()
            self.page++
        })
    }
    
    
    func SAReloadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var url = "http://nian.so/api/user_active.php?page=0&uid=\(Id)&myuid=\(safeuid)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray.addObject(data)
            }
            self.lefttableView!.reloadData()
            self.lefttableView!.headerEndRefreshing()
            self.page = 1
        })
    }
    func SARightReloadData(){
        var url = "http://nian.so/api/user_dream.php?page=0&uid=\(Id)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray2.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray2.addObject(data)
            }
            self.righttableView!.reloadData()
            self.righttableView!.headerEndRefreshing()
            self.page = 1
        })
    }
    
    
    
    
    func urlString()->String
    {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/user_active.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            return 1
        }else{
            if tableView == lefttableView {
                return self.dataArray.count
            }else{
                var thecount:Int
                if ( self.dataArray2.count % 3 > 0 ) {
                    thecount = (self.dataArray2.count)/3 + 1
                }else{
                    thecount = (self.dataArray2.count)/3
                }
                return thecount
            }
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if indexPath.section==0{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as? UserCellTop
            var index = indexPath.row
            c!.userid = Id
            if tableView == lefttableView {
                c!.Seg!.selectedSegmentIndex = 0
            }else{
                c!.Seg!.selectedSegmentIndex = 1
            }
            c!.Seg!.addTarget(self, action: "hello:", forControlEvents: UIControlEvents.ValueChanged)
            c!.foNumber!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "foVC"))
            c!.foedNumber!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "foedVC"))
            cell = c!
        }else{
            if tableView == lefttableView {
                var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? UserCell
                var index = indexPath.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                c!.indexPathRow = index
                c!.goodbye!.addTarget(self, action: "SAdelete:", forControlEvents: UIControlEvents.TouchUpInside)
                c!.edit!.addTarget(self, action: "SAedit:", forControlEvents: UIControlEvents.TouchUpInside)
                c!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c!.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
                c!.tag = index + 10
                cell = c!
            }else{
                var c = tableView.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as? StepCell
                var dictionary:Dictionary<String, String> = ["id":"", "title":"", "img":"", "percent":""]
                var index = indexPath.row * 3
                if index<self.dataArray2.count {
                    c!.data1 = self.dataArray2[index] as NSDictionary
                    c!.img1?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                c!.data1 = dictionary
                }
                if index+1<self.dataArray2.count {
                    c!.data2 = self.dataArray2[index + 1] as NSDictionary
                    c!.img2?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data2 = dictionary
                }
                if index+2<self.dataArray2.count {
                    c!.data3 = self.dataArray2[index + 2] as NSDictionary
                    c!.img3?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data3 = dictionary
                }
                cell = c!
            }
        }
        return cell
    }
    
    func foVC(){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 1
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    func foedVC(){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 2
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func likeclick(sender:UITapGestureRecognizer){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    func imageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController!.pushViewController(imgVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        if indexPath.section==0{
            return  220
        }else{
            if tableView == lefttableView {
                var index = indexPath.row
                var data = self.dataArray[index] as NSDictionary
                return  UserCell.cellHeightByData(data)
            }else{
                return  140
            }
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section != 0 {
            self.lefttableView!.deselectRowAtIndexPath(indexPath, animated: false)
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            var dream = data.stringAttributeForKey("dream")
            if tableView == lefttableView {
                var DreamVC = DreamViewController()
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
        }
    }
    
    func countUp() {      //😍
        self.SAReloadData()
    }
    
    func Editstep() {      //😍
        self.dataArray[self.editStepRow] = self.editStepData!
        var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
        self.lefttableView!.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func setupRefresh(){
        self.lefttableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
        
        self.lefttableView!.addFooterWithCallback({
            self.loadData()
        })
        
        self.righttableView!.addHeaderWithCallback({
            self.SARightReloadData()
        })
        
        self.righttableView!.addFooterWithCallback({
            self.RightloadData()
        })
    }
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    func hello(sender: UISegmentedControl){
        var x = sender.selectedSegmentIndex
        if x == 0 {
            sender.selectedSegmentIndex = 1
            self.righttableView!.hidden = true
            self.lefttableView!.hidden = false
            var y = self.righttableView!.contentOffset.y
            self.lefttableView!.setContentOffset(CGPointMake(0, y), animated: false)
            SAReloadData()
        }else if x == 1 {
            sender.selectedSegmentIndex = 0
            self.lefttableView!.hidden = true
            self.righttableView!.hidden = false
            var y = self.lefttableView!.contentOffset.y
            self.righttableView!.setContentOffset(CGPointMake(0, y), animated: false)
            SARightReloadData()
        }
    }
    
    func SAedit(sender:UIButton){
        var data = self.dataArray[sender.tag] as NSDictionary
        var addstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        addstepVC.isEdit = 1
        addstepVC.data = data
        addstepVC.row = sender.tag
        addstepVC.delegate = self
        self.navigationController!.pushViewController(addstepVC, animated: true)
    }
    
    func SAdelete(sender:UIButton){
        self.deleteId = sender.tag
        var cell:AnyObject
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1){
            cell = sender.superview!.superview!.superview!.superview! as UITableViewCell
            self.deleteViewId = cell.tag
        }else{
            cell = sender.superview!.superview!.superview! as UITableViewCell
            self.deleteViewId = cell.tag
        }
        self.deleteSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.deleteSheet!.addButtonWithTitle("确定")
        self.deleteSheet!.addButtonWithTitle("取消")
        self.deleteSheet!.cancelButtonIndex = 1
        self.deleteSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.deleteSheet {
        if buttonIndex == 0 {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var visibleCells:NSArray = self.lefttableView!.visibleCells()
            for cell  in visibleCells {
                if cell.tag == self.deleteViewId {
                    var newpath = self.lefttableView!.indexPathForCell(cell as UITableViewCell)
                    self.dataArray.removeObjectAtIndex(newpath!.row)
                    self.lefttableView!.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                    self.lefttableView!.reloadData()
                    break
                }
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&sid=\(self.deleteId)", "http://nian.so/api/delete_step.php")
            if(sa == "1"){
            }
            })
        }
        }else if actionSheet == self.userMoreSheet {
            if buttonIndex == 0 {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as String
                var safeshell = Sa.objectForKey("shell") as String
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)", "http://nian.so/api/ban.php")
                    if sa == "1" {
                        dispatch_async(dispatch_get_main_queue(), {
                            UIView.showAlertView("好了", message: "拖进小黑屋了...")
                        })
                    }
                })
            }
        }
    }
    
    
    func DreamimageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController!.pushViewController(imgVC, animated: true)
    }
    
    
}
