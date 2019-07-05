//
//  VideoViewController.swift
//  WebRTC
//
//  Created by Stasel on 21/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import UIKit
import WebRTC
import WebKit

class VideoViewController: UIViewController , WKUIDelegate, WKNavigationDelegate {

    @IBOutlet private weak var localVideoView: UIView?
    @IBOutlet private weak var remoteVideoView: UIView?
    @IBOutlet weak var webFrame: UIView!
    private var webRTCClient: WebRTCClient!
    var webView: WKWebView!

    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient
        super.init(nibName: String(describing: VideoViewController.self), bundle: Bundle.main)
        
    }
    static func instantiate(webRTCClient: WebRTCClient) -> VideoViewController
    {
        let videoViewController =  UIStoryboard(name: "iOS_converted", bundle: nil).instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
        videoViewController.webRTCClient = webRTCClient
        return videoViewController
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
//    override func loadView() {
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
        
        if let localVideoView = self.localVideoView {
            self.embedView(localRenderer, into: localVideoView)
        }
        if let remoteVideoView = self.remoteVideoView {
            self.embedView(remoteRenderer, into: remoteVideoView)
        }
//        self.embedView(remoteRenderer, into: self.view)
//        self.view.sendSubviewToBack(remoteRenderer)
        
        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
//        webView = WKWebView(frame: self.webFrame.frame, configuration: webConfiguration)
//        webView.uiDelegate = self

//        self.view.sendSubviewToBack(remoteRenderer)
//        self.view.sendSubviewToBack(webView)
        
        self.webFrame.isOpaque = false
        self.webFrame.backgroundColor = UIColor.clear
        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webFrame.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webFrame.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webFrame.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webFrame.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: webFrame.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webFrame.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: webFrame.heightAnchor).isActive = true
        
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        self.openUrl()
    }
    
    func openUrl() {
//        let url = URL(string: "http://192.168.1.235:8080/?userid=aaa")
        let url = URL(string: "http://169.254.110.219:8080/?role=p")
//        let url = URL(string: "http://169.254.110.219:8080")
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
    
    @IBAction private func backDidTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
