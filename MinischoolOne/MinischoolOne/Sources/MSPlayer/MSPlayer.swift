//
//  MSPlayer.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 03/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation
import WebRTC
import WebKit

public class MSPlayer : NSObject {

    var localVideoView: UIView!
    var remoteVideoView: UIView!
    var webView: WKWebView!
    weak var containerView: UIView!
    weak var viewController: UIViewController?

    public init(_ containerView: UIView, viewController: UIViewController) {
        super.init()
//      
        self.containerView = containerView
        self.viewController = viewController

//        self.initVideoView()

        // webview 생성

        self.initWebview()
        
//        self.containerView.sendSubviewToBack(self.webView)
    }
    
    public func run() {
        self.openUrl("http://172.16.3.95:8080/?role=s&id=aaa&ck=bbb")
        //self.openUrl("http://192.168.1.57:8080/?role=s&id=aaa&ck=bbb")

    }
}
