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
    public var classKeyAndToken: String!
    public var role: String!
    public var serviceAppVersion: String!
    public var frameworkVersion: String! = "1.0"

    weak var containerView: UIView!
    weak var viewController: UIViewController?
    public weak var delegate: MSPlayerDelegate?
    
    public init(_ containerView: UIView, viewController: UIViewController, serviceAppVersion: String, url: String, classKeyAndToken: String, role: String) {
        super.init()

        self.containerView = containerView
        self.viewController = viewController
        self.serviceAppVersion = serviceAppVersion

        self.url = url

        self.classKeyAndToken = classKeyAndToken
        self.role = role

        self.initWebRTC()
        
        self.initWebview()
        
        self.delegate?.MSPlayer(self, didChangedStatus: MSPlayerStatus.waiting)
    }
    
    public func run() {
        let urlComplete = "\(self.url!)?hash=\(self.classKeyAndToken!)&role=\(self.role!)"
        print(urlComplete)
        self.openUrl(urlComplete)
    }
}
