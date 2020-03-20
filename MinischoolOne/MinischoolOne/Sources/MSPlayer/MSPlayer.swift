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
//    internal var uiWebView: UIWebView!

    public var serverAddress: String!
    public var classKeyAndToken: String!
    public var role: String!
    public var serviceAppVersion: String!
    public var frameworkVersion: String! = "1.0"

    public weak var containerView: UIView!
    public var baseView: UIView!
    weak var viewController: UIViewController?
    public weak var delegate: MSPlayerDelegate?
    
    private var observer: NSKeyValueObservation?
    var localVideoViewOriginalFrame: Frame!
    var remoteVideoViewOriginalFrame: Frame!
    
    private var urlComplete = ""
    
    var backLoggingOn = false
    
    var useWKWebview = true
    
    let maxWidth = CGFloat(1920)
    let maxHeight = CGFloat(1080)
    
    var movieClipLayers : [Int: AVPlayerLayer] = [:]
    var movieClips : [Int: UIView] = [:]
    var backgroundImages : [Int: UIImage?] = [:]
    var backgroundImage : UIImageView!
    var resourceList: [Resource] = []
    
    var timer : Timer?
        
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
        
        self.initBackgroundView()
        
        self.initWKWebview()

        observer = self.baseView.layer.observe(\.bounds) { object, _ in
            print("baseView changing bounds: \(object.bounds)")
            self.relocateLocalVideoFrame()
            self.relocateRemoteVideoFrame()
        }
    }
    
    private func initBackgroundView() {

        print("initBackgroundView self.containerView.frame: \(self.containerView.frame)")

        let bounds = self.containerView.bounds
        
        if bounds.width / bounds.height <= 16 / 9 { // ex: ipad
            self.baseView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width * 9 / 16))
        }else{ // wide - ex: iphone xs
            self.baseView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.height * 16 / 9, height: bounds.height))
        }
        
        let backgroundColorView = UIView(frame: self.baseView.bounds)
        backgroundColorView.backgroundColor = UIColor.white
        backgroundColorView.center = self.containerView.center
        self.containerView.addSubview(backgroundColorView)
        
        self.containerView.backgroundColor = UIColor.black
        self.containerView.addSubview(baseView)
        self.baseView.autoresizingMask    = [.flexibleHeight, .flexibleWidth]

        self.baseView.center = self.containerView.center
        
        print("initBackgroundView self.baseView.frame: \(self.baseView.frame)")

    }
    
    @objc public func run() {
        print("MSPlayer urlComplete: \(urlComplete)")
        self.openUrl(urlComplete)
    }
    
    @objc public func closeAll() {
        print("[mini] closeAll")
        self.wkWebView?.stopLoading()
        self.wkWebView = nil
        self.stopWebRTC()
        
        self.baseView.removeFromSuperview()
        
        self.movieClipLayers.removeAll()
        self.movieClips.removeAll()
        self.backgroundImages.removeAll()
        self.resourceList.removeAll()
        self.changeStatusTo(MSPlayerStatus.closed)
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
