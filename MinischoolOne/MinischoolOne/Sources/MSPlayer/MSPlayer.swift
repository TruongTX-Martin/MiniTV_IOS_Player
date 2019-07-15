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

public protocol MSPlayerDelegate: class {
    func MSPlayer(_ player: MSPlayer, didChangedStatus newStatus: MSPlayerStatus)
}
public class MSPlayer : NSObject {

    internal var localVideoView: UIView!
    internal var remoteVideoView: UIView!
    internal var webView: WKWebView!
    
    public var url: String!
    public var classKey: String!
    public var token: String!
    public var role: String!
    public var serviceAppVersion: String!
    public var frameworkVersion: String! = "1.0"

    weak var containerView: UIView!
    weak var viewController: UIViewController?
    public weak var delegate: MSPlayerDelegate?
    
    public init(_ containerView: UIView, viewController: UIViewController, serviceAppVersion: String, url: String, classKey: String, token: String, role: String) {
        super.init()

        self.containerView = containerView
        self.viewController = viewController
        self.serviceAppVersion = serviceAppVersion

        self.url = url
        //https://stage-p2.minischool.co.kr/preview/Y2sxNTYxOTY2MjMxMjY1e4a0a4be-4924-4557-a28a-025ade7451b1?ref=a
        self.classKey = classKey
        self.token = token
        self.role = role

        self.initWebview()
        
        self.delegate?.MSPlayer(self, didChangedStatus: MSPlayerStatus.waiting)
    }
    
    public func run() {
//        let urlComplete = "\(self.url!)?hash=\(self.classKey!)\(self.token!)&role=\(self.role!)"
//        self.openUrl(urlComplete)

        self.openUrl("http://172.16.3.95:8080/?role=s&id=aaa&ck=bbb")
        //self.openUrl("http://192.168.1.57:8080/?role=s&id=aaa&ck=bbb")
    }
}
