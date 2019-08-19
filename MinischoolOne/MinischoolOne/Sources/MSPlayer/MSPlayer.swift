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
            print(object.bounds)
            self.relocateLocalVideoFrame()
            self.relocateRemoteVideoFrame()
        }
    }
    
    private func initBackgroundView() {

        print("initBackgroundView self.containerView.frame: \(self.containerView.frame)")
        self.containerView.setNeedsLayout()
        self.containerView.setNeedsDisplay()
        self.baseView = UIView(frame: CGRect(x: 0, y: 0, width: self.containerView.bounds.width, height: self.containerView.bounds.width * 9 / 16))
        self.containerView.addSubview(baseView)
//        self.baseView.autoresizingMask    = [.flexibleHeight, .flexibleWidth]

        self.baseView.center = self.containerView.center
        
        print("initBackgroundView self.baseView.frame: \(self.baseView.frame)")

//        self.containerView.translatesAutoresizingMaskIntoConstraints = false
//        self.baseView.translatesAutoresizingMaskIntoConstraints = false
//        self.baseView.setNeedsUpdateConstraints()
        
//        self.baseView.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
//        self.baseView.rightAnchor.constraint(equalTo: self.containerView.rightAnchor).isActive = true
//        self.baseView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor).isActive = true
//        self.baseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
//        self.baseView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor).isActive = true

        
//        self.backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 9))
//        self.backgroundImage.backgroundColor = .green
//        self.baseView.addSubview(self.backgroundImage)
//
//        self.backgroundImage.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor).isActive = true
//        self.backgroundImage.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor).isActive = true
//        self.backgroundImage.rightAnchor.constraint(equalTo: self.baseView.rightAnchor).isActive = true
//        self.backgroundImage.leftAnchor.constraint(equalTo: self.baseView.leftAnchor).isActive = true

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
        
        self.movieClipLayers.removeAll()
        self.movieClips.removeAll()
        self.backgroundImages.removeAll()
        self.resourceList.removeAll()
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
