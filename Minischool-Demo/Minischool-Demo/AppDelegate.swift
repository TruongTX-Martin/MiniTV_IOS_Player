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
            let scheme = components.scheme
            //, let infraPath = components.host
            //, let rest = components.path
            //, let params = components.queryItems
            else {
                print("Invalid URL")
                return false
        }
        
        // msp3://ekp-dev/preview/Y2sxNTY0MjE5ODQxNDc5dG9rZW5WMDAwMDAwMDAxQTAwMDAwMDAwODE0ODY0NDg4Mzg3NDk=?lang=en
        print("scheme = \(scheme)")
        
        let protocolHeader = "https"

        let targetUrl = url.absoluteString.replacingOccurrences(of: scheme, with: protocolHeader)
        
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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}

