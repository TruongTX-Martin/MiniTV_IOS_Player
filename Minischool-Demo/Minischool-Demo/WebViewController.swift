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
        //let tmpUrl = "https://192.168.0.7:8080/student.html?hash=B5PAwLRboIAqTMwhD0XV67221c364e8a40cf98f80d30ac391e18&wz=0"
        self.webView.isHidden = true
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
            // 학생이 리소스 로딩을 완료하고 서버에 접속 시 발생 (수업 시작 전)
            print("[mini] waiting")
        case .started:
            // 교사가 수업 시작 버튼을 클릭 시 발생
            print("[mini] started")
        case .ended:
            // 교사가 수업 종료 버튼 클릭 시, 오류 발생 시 (플레이어 뷰는 유지하고 있는 상태)
            print("[mini] ended")
        case .closed:
            // 수업 종료, 오류 화면에서 "BACK" 버튼을 클릭 시 (플레이어 뷰 사라짐)
            self.webView.isHidden = false
        default:
            print("[mini] errorOcccured")
        }
    }
    
    func MSPlayer(_ player: MSPlayer, errorOccured error: Error) {
        print("[mini]", error.localizedDescription)
    }
    
}
