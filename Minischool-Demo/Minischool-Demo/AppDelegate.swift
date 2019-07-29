//
//  AppDelegate.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {

        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")
        print("url = \(url)")
        
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let infraPath = components.host,
            let rest = components.path,
            let params = components.queryItems else {
                print("Invalid URL or album path missing")
                return false
        }
        
        // msp3://ekp-dev/preview/Y2sxNTY0MjE5ODQxNDc5dG9rZW5WMDAwMDAwMDAxQTAwMDAwMDAwODE0ODY0NDg4Mzg3NDk=?lang=en
        print("infraPath = \(infraPath)")
        print("rest = \(rest)")
        print("params = \(params)")
        
        var targetPath = infraPath
        switch infraPath {
        case "ekp-dev":
            targetPath = "dev-p3.ekidpro.com"
        case "ms-stage":
            targetPath = "stage-p3.minischool.co.kr"
        case "hs-stage":
            targetPath = "stage-hs-p3.minischool.co.kr"
        default:
            targetPath = infraPath
        }
        let targetUrl = url.absoluteString.replacingOccurrences(of: infraPath, with: targetPath).replacingOccurrences(of: "msp3", with: "http")
        
        print("targetUrl: \(targetUrl)")
        UserDefaults.standard.set(targetUrl, forKey: "url")

        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let containerViewController = storyboard.instantiateViewController(withIdentifier: "ContainerViewController")

        self.window?.rootViewController = containerViewController
        self.window?.makeKeyAndVisible()

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
    }

}

