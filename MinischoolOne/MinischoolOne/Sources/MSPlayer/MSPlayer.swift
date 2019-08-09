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

@objc
public protocol MSPlayerDelegate: class {
    func MSPlayer(_ player: MSPlayer, didChangedStatus newStatus: MSPlayerStatus)
    func MSPlayer(_ player: MSPlayer, errorOccured error: Error)
}

@objc(MSPlayer)
public class MSPlayer : NSObject {

    internal var localVideoView: UIView!
    internal var remoteVideoView: UIView!
    internal var wkWebView: WKWebView!
    internal var webView2: UIWebView!

    public var serverAddress: String!
    public var classKeyAndToken: String!
    public var role: String!
    public var serviceAppVersion: String!
    public var frameworkVersion: String! = "1.0"

    public weak var containerView: UIView!
    weak var viewController: UIViewController?
    public weak var delegate: MSPlayerDelegate?
    
    private var observer: NSKeyValueObservation?
    var localVideoViewOriginalFrame: Frame!
    var remoteVideoViewOriginalFrame: Frame!
    
    private var urlComplete = ""
    
    var backLoggingOn = false
    
    @objc public init(_ containerView: UIView, viewController: UIViewController?, serviceAppVersion: String, serverAddress: String, classKeyAndToken: String, role: String) {
        super.init()
        
        self.containerView = containerView
        self.viewController = viewController
        self.serviceAppVersion = serviceAppVersion
        
        self.serverAddress = serverAddress
        
        self.classKeyAndToken = classKeyAndToken
        self.role = role
        
//        urlComplete = "\(self.serverAddress!)/student.html?hash=\(self.classKeyAndToken!)&role=\(self.role!)&playsinline=1"
        urlComplete = "\(self.serverAddress!)/student/\(self.classKeyAndToken!)&role=\(self.role!)"

        self.initialize()
    }

    
    @objc public init?(_ containerView: UIView, viewController: UIViewController?, serviceAppVersion: String, url: String) {
        super.init()
        
        self.containerView = containerView
        self.viewController = viewController
        self.serviceAppVersion = serviceAppVersion
        
        self.serverAddress = url
        
        urlComplete = url

        self.initialize()
        
        self.classKeyAndToken = url.betweenChar("/", "?")
    }

    private func initialize() {
//        self.soundPrepare()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.initWebview()
        
        observer = self.containerView.layer.observe(\.bounds) { object, _ in
            print(object.bounds)
            self.relocateLocalVideoFrame()
            self.relocateRemoteVideoFrame()
        }
    }
    
    @objc public func run() {
        print("MSPlayer urlComplete: \(urlComplete)")
        self.openUrl(urlComplete)
    }
    
    @objc public func closeAll() {
        print("closeAll")
        self.stopWebRTC()
//        webView.load(URLRequest(url: URL(string:"about:blank")!))
        self.wkWebView = nil
    }
    
    public func soundPrepare() {
        print("soundPrepare")
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }    
}
