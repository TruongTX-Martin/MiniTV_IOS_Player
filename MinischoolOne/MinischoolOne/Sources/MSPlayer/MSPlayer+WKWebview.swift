//
//  MSPlayer+Webview.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation
import WebKit

extension MSPlayer : WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler{
    
    func initWKWebview() {
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "jsToNative")
        
        let js = "window.isNative = true; window.NativeInfo = {serviceAppVersion: '\(self.serviceAppVersion!)', frameworkVersion: '\(self.frameworkVersion!)'}"
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsPictureInPictureMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []

        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.userContentController = contentController
        
        self.baseView.isOpaque = false
        self.baseView.backgroundColor = UIColor.clear
        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: self.baseView.frame.size)
        self.wkWebView = WKWebView (frame: customFrame , configuration: webConfiguration)
        self.wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(view: self.wkWebView, z: ZINDEX.Canvas.rawValue)
        
        wkWebView.isOpaque = false
        wkWebView.backgroundColor = UIColor.clear
        wkWebView.scrollView.backgroundColor = UIColor.clear
        wkWebView.scrollView.bounces = false

        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        wkWebView.isUserInteractionEnabled = true
        
        print("self.wkWebView.frame: \(self.wkWebView.frame)")
    }
    
    func openEmbeded() {
        let localFile = Bundle.main.path(forResource: "page", ofType: "html")
        let url = URL(fileURLWithPath: localFile!)
        let request = URLRequest(url: url)

        wkWebView.load(request)
    }

    
    public func openUrlWK(_ urlString: String) {
        let url = URL(string: urlString)

        print("openUrl containerView.frame: \(self.baseView.frame)")
        let request = URLRequest(url: url!)
        wkWebView.load(request)
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = webView
        }

        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = webView
        }
        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = webView
        }
        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let url = webView.url
        print("didFinish \(url as Any)")
    }
    
    public func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
        {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        }
        else
        {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    func callJSWK(jsFunctionName: String, data: String) {
        let stringJS = "\(jsFunctionName)(\(data))"
        DispatchQueue.main.async {
            print("callJS: \(stringJS)")
            guard let webView = self.wkWebView else {
                return
            }
            webView.evaluateJavaScript(stringJS, completionHandler: {(result, error) in
                if let result = result {
                    print(result)
                }
            })
        }
    }
    
    //Called from JS
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == "jsToNative" {
            
            if let dictionary: [String: String] = message.body as? Dictionary {

                self.JSToNative(dictionary: dictionary)
            }
        }
    }
}

