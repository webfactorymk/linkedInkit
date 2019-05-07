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

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = window ?? UIWindow(frame: UIScreen.main.bounds)
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

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        if LinkedInKit.shouldHandleUrl(url) {
            return LinkedInKit.application(application,
                                           openURL: url,
                                           sourceApplication: sourceApplication,
                                           annotation: annotation as AnyObject)
        }
        
        return true
    }
}
