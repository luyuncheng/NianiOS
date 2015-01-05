//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//  change the world

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = BGColor
        var navigationViewController = UINavigationController(rootViewController: WelcomeViewController())
        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
        navigationViewController.navigationBar.clipsToBounds = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.window!.rootViewController = navigationViewController
        self.window!.makeKeyAndVisible()
        
        if application.respondsToSelector("isRegisteredForRemoteNotifications") {
            var settings = UIUserNotificationSettings(forTypes: (UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge), categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge)
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppDeactive", object: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppActive", object: nil)
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var newDeviceToken = SAReplace("\(deviceToken)", "<", "")
            newDeviceToken = SAReplace("\(newDeviceToken)", ">", "")
            newDeviceToken = SAReplace("\(newDeviceToken)", " ", "")
            Sa.setObject(newDeviceToken, forKey:"DeviceToken")
            Sa.synchronize()
        })
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        delay(1, { () -> () in
            NSNotificationCenter.defaultCenter().postNotificationName("AppURL", object: "\(url)")
        })
        return true
    }
    
}

