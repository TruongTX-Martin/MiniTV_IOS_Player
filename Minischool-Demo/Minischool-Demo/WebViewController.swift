//
//  WebViewController.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 30/08/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import UIKit
import WebKit
import MinischoolOne

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, MSPlayerDelegate {

    
    var player: MSPlayer!
    @IBOutlet weak var webView: WKWebView!
    
    //var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.blue
        
        //self.view = self.webView
        self.webView.navigationDelegate = self
        let url = URL(string: "https://dev-admin.minischool.co.kr/bts")
        //let url = URL(string: "https://naver.com")
        let request = URLRequest(url: url!)
        self.webView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation:
   WKNavigation!, withError error: Error) {
       print(error.localizedDescription)
   }
   
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           // show indicator
        //print("111")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString {
            //urlStr is what you want
            
            if urlStr.contains("bts") {
                print("allow URL ", urlStr)
                decisionHandler(.allow)
            }else{
                print("cancel URL ", urlStr)
                decisionHandler(.cancel)
                self.runPlayer(urlStr: urlStr)
            }
        }

        //decisionHandler(.allow)
    }
    
    func runPlayer(urlStr: String) {
        print("Run >> ", urlStr)
        self.webView.isHidden = true;
        let serviceAppVersion = "1.0"
        //let role = ""
        self.player = MinischoolOne.MSPlayer(self.view, viewController: self, serviceAppVersion: serviceAppVersion, url: urlStr)
        self.player.delegate = self
        self.player.run()
    }
    
    // MSPlayer Delegate
    func MSPlayer(_ player: MSPlayer, didChangedStatus newStatus: MSPlayerStatus) {
        switch newStatus {
        case .waiting:
            print("[mini] waiting")
        case .started:
            print("[mini] started")
        case .ended:
            print("[mini] ended")
            self.player.closeAll()
            self.webView.isHidden = false
        default:
            print("[mini] errorOcccured")
        }
    }
    
    func MSPlayer(_ player: MSPlayer, errorOccured error: Error) {
        print("[mini]", error.localizedDescription)
    }
    
}
