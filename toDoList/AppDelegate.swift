//
//  AppDelegate.swift
//  toDoList
//
//  Created by Mohamed Sobhi  Fouda on 2/15/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Parse
import Instabug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // Back4App Config (parse)
        let configuration = ParseClientConfiguration {
            $0.applicationId = PARSE_APP_ID
            $0.clientKey = PARSE_CLIENT_KEY
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        // Admob Config App ID
        if(admobEnable){
           GADMobileAds.configure(withApplicationID: admobAppId)
        }
        
        // Navigation Bar Style
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = baseColor
        UINavigationBar.appearance().tintColor = navigationBarTintColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: font18base!,NSAttributedString.Key.foregroundColor : UIColor(netHex: 0xffffff)
        ]
        
        // TabBar Style
        //UITabBar.appearance().barTintColor = UIColor(netHex: 0x1D65A6)
        UITabBar.appearance().tintColor = tabBarTintColor
        
        
        // Config TabBar
        let tabBarController = UITabBarController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabViewController1 = storyboard.instantiateViewController(withIdentifier: "homeNib") as! homeTask
        tabViewController1.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "home"),
            tag: 1)
        tabViewController1.tabBarItem.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
        let homeNv = UINavigationController(rootViewController: tabViewController1)
        
        let tabViewController2 = storyboard.instantiateViewController(withIdentifier: "calendarNib") as! calendarTask
        tabViewController2.tabBarItem = UITabBarItem(
            title: nil,
            image:UIImage(named: "calendarTab") ,
            tag: 2)
        tabViewController2.tabBarItem.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
        let calanderNv = UINavigationController(rootViewController: tabViewController2)
        
        
        let controllers = [homeNv,calanderNv]
        tabBarController.viewControllers = controllers
        window?.rootViewController = tabBarController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

}

