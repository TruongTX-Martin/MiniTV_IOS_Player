//
//  WebViewController.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 29/06/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController , WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webFrame: UIView!
    @IBOutlet weak var wkView: WKWebView!
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let webConfiguration = WKWebViewConfiguration()

        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webFrame.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webFrame.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webFrame.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webFrame.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: webFrame.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webFrame.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: webFrame.heightAnchor).isActive = true
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false

        let url = URL(string: "https://media.daum.net/")
        let request = URLRequest(url: url!)
        webView.load(request)
        
        self.wkView.load(request)
        self.wkView.navigationDelegate = self
    }

    static func instantiate() -> WebViewController
    {
        let vc =  UIStoryboard(name: "iOS_converted", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        return vc
    }
    
    @IBAction private func backDidTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
