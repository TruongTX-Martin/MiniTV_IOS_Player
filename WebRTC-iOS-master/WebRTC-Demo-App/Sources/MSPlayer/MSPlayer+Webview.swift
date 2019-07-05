//
//  MSPlayer+Delegate.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation
import WebKit

extension MSPlayer : WKUIDelegate, WKNavigationDelegate{
    
    func initWebview() {
        let webConfiguration = WKWebViewConfiguration()
        //        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        //        webView = WKWebView(frame: self.containerView.frame, configuration: webConfiguration)
        //        webView.uiDelegate = self
        
        
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
    
    func openUrl() {
        let url = URL(string: "http://169.254.143.6:8080/?role=p")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
}
