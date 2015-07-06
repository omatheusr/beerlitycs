//
//  AppDelegate.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 20/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse
import Bolts
//import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Google Maps
//        GMSServices.provideAPIKey("AIzaSyDM2AN03SBXVEkq7RJjjbRCFAOC0PUEiog")
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("3H0KFAy9db3ETpff9EfIEVnMgbxhe84gztqgDtJE",
            clientKey: "TsLEsKGDcv4dz1EqbiFlMNRwTwDQHr7eXP9CPJvd")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Initialize Facebook
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)

        let color = UIColor(red: 55.0/255.0, green: 61.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        UITabBar.appearance().barTintColor = color
        UITabBar.appearance().tintColor = UIColor(red: 255.0/255.0, green: 151.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: UIControlState.Selected)

        let colorNav = UIColor(red: 229.0/255.0, green: 110.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        let font = UIFont(name: "AvenirNext-Regular", size: 20)
        if let font = font {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }

        UINavigationBar.appearance().barTintColor = colorNav
        UINavigationBar.appearance().opaque = true
        UINavigationBar.appearance().translucent = true
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(types)
        }

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Facebook Fuctions-----------------------------------------------------------------------
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    //-----------------------------------------------------------------------------------------
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        let currentUser = UserDefaultsManager.getUserId

        if let userInfo = userInfo, request = userInfo["request"] as? String {
            
            if UserDefaultsManager.getUserId == nil {
                reply(["reply": false])
            } else {
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum);
                var bgTask = UIBackgroundTaskIdentifier()
                bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                    
                    
                    UIApplication.sharedApplication().endBackgroundTask(bgTask)
                    bgTask = UIBackgroundTaskInvalid
                }
                
                if(request == "getRankingPosition") {
                    let stats = StatsManager()
                    
                    stats.get(currentUser, callback: { (position, error) -> () in
                        if(error == nil) {
                            let strPosition : String! = String(stringInterpolationSegment: position) as String
                            reply(["reply": strPosition!])
                        } else {
                            println("erro")
                        }

                        UIApplication.sharedApplication().endBackgroundTask(bgTask)
                        bgTask = UIBackgroundTaskInvalid
                    })
                } else if(request == "getStatus") {
                    let statusControl = StatsManager()
                    
                    statusControl.alcoholContentInBlood(currentUser!, callback: { (alcoholInBlood, type, error) -> () in
                        if(error == nil){
                            let statusReply = [NSString(format: "%.2f",  alcoholInBlood!) as String, type!]
//                            statusReply.setValue(alcoholInBlood!, forKey: 0)
//                            statusReply.setValue(type!, forKey: 1)
                            reply(["reply": statusReply])
                       } else {
                            println(error)
                        }

                        UIApplication.sharedApplication().endBackgroundTask(bgTask)
                        bgTask = UIBackgroundTaskInvalid
                    })
                }
            }
        }
    }
}

