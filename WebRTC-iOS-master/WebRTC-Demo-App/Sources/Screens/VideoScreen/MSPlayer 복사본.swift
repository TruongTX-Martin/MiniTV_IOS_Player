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


class MSPlayer : NSObject, WKUIDelegate, WKNavigationDelegate {

    var localVideoView: UIView!
    var remoteVideoView: UIView!
    var webView: WKWebView!
    weak var containerView: UIView!

    private var signalClient: SignalingClient!
    private var webRTCClient: WebRTCClient!

    
//        init(localVideoView: UIView, remoteVideoView: UIView, containerView: UIView, webRTCClient: WebRTCClient) {
    init(localVideoView: UIView, remoteVideoView: UIView, containerView: UIView, webRTCClient: WebRTCClient) {
        super.init()
//        self.webRTCClient = webRTCClient
        
        // client 초기화 싱글톤으로 이동?
        let config = Config.default
        self.signalClient = SignalingClient(serverUrl: config.signalingServerUrl)
//        self.webRTCClient = WebRTCClient(iceServers: config.webRTCIceServers)
        self.webRTCClient = webRTCClient

        // video view 생성(local, remote)
        self.localVideoView = UIView(frame: CGRect(x: 0, y: containerView.frame.height * 0.5, width: 100, height: 50))
        self.remoteVideoView = UIView(frame: CGRect(x: containerView.frame.width * 0.5, y: containerView.frame.height * 0.5, width: 100, height: 50))
//        self.localVideoView = localVideoView
//        self.remoteVideoView = remoteVideoView

        //위치 설정
        self.initVideoView()

        // webview 생성
        self.containerView = containerView

        self.initWebview()
        
        
        self.containerView.addSubview(self.localVideoView)
        self.containerView.addSubview(self.remoteVideoView)
        self.containerView.sendSubviewToBack(webView)
    }
    
    func initVideoView() {
        
        #if arch(arm64)
        // Using metal (arm64 only)
        let localRenderer = RTCMTLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCMTLVideoView(frame: self.remoteVideoView?.frame ?? CGRect.zero)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        #else
        // Using OpenGLES for the rest
        let localRenderer = RTCEAGLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCEAGLVideoView(frame: self.remoteVideoView?.frame ?? CGRect.zero)
        #endif
        //좌우반전(거울처럼)
        localRenderer.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)

        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
        
        if let localVideoView = self.localVideoView {
            self.embedView(localRenderer, into: localVideoView)
        }
        if let remoteVideoView = self.remoteVideoView {
            self.embedView(remoteRenderer, into: remoteVideoView)
        }

    }
    
    func initWebview() {
        let webConfiguration = WKWebViewConfiguration()
        //        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        //        webView = WKWebView(frame: self.containerView.frame, configuration: webConfiguration)
        //        webView.uiDelegate = self
        
        //        self.view.sendSubviewToBack(remoteRenderer)
        //        self.view.sendSubviewToBack(webView)
        
        self.containerView.isOpaque = false
        self.containerView.backgroundColor = UIColor.clear
        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.containerView.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(webView)
        webView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
    }
    
    func run() {
        self.openUrl()
    }
    
    func openUrl() {
        let url = URL(string: "http://169.254.143.6:8080/?role=p")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }
}
