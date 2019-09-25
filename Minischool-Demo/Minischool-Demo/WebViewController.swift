//
//  WebViewController.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 30/08/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        let url = URL(string: "https://dev-admin.ekidpro.com/bts")
        webView.load(URLRequest(url: url!))
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let title = NSLocalizedString("OK", comment: "OK Button")
        let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.evaluateJavaScript("alert('Hello from evaluateJavascript()')", completionHandler: nil)
//        let url = URL(string: "https://192.168.0.184:8080/student.html?hash=Y2sxNTY2NTQ5OTk4MTA2b75e3d8d31734854a0be338901a68169?lang=en")
//        let url = URL(string: "https://dev-p3.ekidpro.com/student/Y2sxNTY2NTUyMDM5NzAwb75e3d8d31734854a0be338901a68169?lang=en")
//        CustomeSchemeHandler.sharedInstance.run(url: url!, vc: self)
    }
    
    // WKWebViewNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("msp3") {
            print("url = \(url)")
            decisionHandler(.cancel)

            CustomeSchemeHandler.sharedInstance.run(url: url, vc: self)
            return
        }
        // This is a HTTP link
        //open(url: url)
        decisionHandler(.allow)
    }
}

extension URLRequest {
    var isHttpLink: Bool {
        return self.url?.scheme?.contains("http") ?? false
    }
}
