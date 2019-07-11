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
        self.viewController = viewController


//        self.initVideoView()

        // webview 생성
        self.containerView = containerView

        self.initWebview()
        
//        self.containerView.sendSubviewToBack(self.webView)
    }
    
    public func run() {
        self.openUrl()
    }
}
