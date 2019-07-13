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
    
    func initWebview() {
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "jsToNative")
        
        let userScript = WKUserScript(source: "window.isNative = true;", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        
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
        webView.scrollView.bounces = false

        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    func openUrl() {
//        let localFile = Bundle.main.path(forResource: "page", ofType: "html")
//        let url = URL(fileURLWithPath: localFile!)
//        let request = URLRequest(url: url)
//        self.createLocalVideo(Frame(x: 20, y: 50, z: 99, width: 50, height: 100))

//        let url = URL(string: "http://172.16.3.95:8080/?role=s&id=aaa&ck=bbb")
        let url = URL(string: "http://192.168.1.57:8080/?role=s&id=aaa&ck=bbb")
        
        print("openUrl \(url.debugDescription)")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
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
        
        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let url = webView.url
        print("didFinish \(url as Any)")
    }
    func callJS(jsFunctionName: String, data: String) {
        let stringJS = "\(jsFunctionName)(\(data))"
        DispatchQueue.main.async {
            print("callJS: \(stringJS)")
            self.webView.evaluateJavaScript(stringJS, completionHandler: {(result, error) in
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
