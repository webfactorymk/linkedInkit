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
        
        let configuration = LinkedInConfiguration(withClientID: "77zcp4j2f9sver",
                                                  clientSecret: "svXOeAMVjqfvyvM7",
                                                  state: "qwertyuiop",
                                                  permissions: ["r_basicprofile","r_emailaddress"],
                                                  redirectURL: "http://www.macedonia2025.com",
                                                  appID: "4428373")
        LinkedInKit.setup(withConfiguration: configuration)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) { }

    func applicationDidEnterBackground(application: UIApplication) { }

    func applicationWillEnterForeground(application: UIApplication) { }

    func applicationDidBecomeActive(application: UIApplication) { }

    func applicationWillTerminate(application: UIApplication) { }

}
