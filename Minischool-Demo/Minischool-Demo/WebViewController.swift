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

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let msp = MSPlayer(self.view, viewController: self, serviceAppVersion: "1.0", url: "https://dev-admin.ekidpro.com/bts")
        msp?.run()
    }
}
