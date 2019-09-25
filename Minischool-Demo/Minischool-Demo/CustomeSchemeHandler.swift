//
//  CustomeSchemeHandler.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 02/09/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation
import UIKit


class CustomeSchemeHandler {
    
    static let sharedInstance = CustomeSchemeHandler()

    var window: UIWindow?

    init() {
    }
    
    public func run(url: URL, vc: UIViewController? = nil) {
        
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let scheme = components.scheme
            //, let infraPath = components.host
            //, let rest = components.path
            //, let params = components.queryItems
            else {
                print("Invalid URL")
                return
        }
        
        print("scheme = \(scheme)")
        
        let protocolHeader = "https"
        
        let targetUrl = url.absoluteString.replacingOccurrences(of: scheme, with: protocolHeader)
        
        print("targetUrl: \(targetUrl)")
        UserDefaults.standard.set(targetUrl, forKey: "url")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let containerViewController = storyboard.instantiateViewController(withIdentifier: "ContainerViewController")
        
        if vc != nil {
            //vc!.present(containerViewController, animated: true, completion: nil)
            vc!.performSegue(withIdentifier: "ShowContainer", sender: vc)
        }else{
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            self.window?.rootViewController = containerViewController
            self.window?.makeKeyAndVisible()
        }

    }
}
