//
//  AppDelegate.swift
//  LinkedInKit
//
//  Created by Mariana on 07/07/2016.
//  Copyright (c) 2016 Mariana. All rights reserved.
//

import UIKit
import LinkedInKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = window ?? UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        let permissionsArray = ["r_basicprofile","r_emailaddress","rw_company_admin", "w_share"]
        let configuration = LinkedInConfiguration(withClientID: "78mqqrk2mcaied",
                                                  clientSecret: "4o2gtBTLePRKJi4H",
                                                  state: "qwertyuiop",
                                                  permissions: permissionsArray,
                                                  redirectURL: "http://www.google.com",
                                                  appID: "4245054")
        LinkedInKit.setup(withConfiguration: configuration)
        LinkedInKit.authViewControllerDelegate = DesignManager.sharedManager
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) { }

    func applicationDidEnterBackground(application: UIApplication) { }

    func applicationWillEnterForeground(application: UIApplication) { }

    func applicationDidBecomeActive(application: UIApplication) { }

    func applicationWillTerminate(application: UIApplication) { }

    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        if LinkedInKit.shouldHandleUrl(url) {
            return LinkedInKit.application(application,
                                           openURL: url,
                                           sourceApplication: sourceApplication,
                                           annotation: annotation)
        }
        
        return true
    }
}
