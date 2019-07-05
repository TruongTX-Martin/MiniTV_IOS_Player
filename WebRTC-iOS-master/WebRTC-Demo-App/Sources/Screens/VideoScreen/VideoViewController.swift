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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player = MSPlayer(containerView: self.webFrame!)
        player.run()

    }
    
    @IBAction private func backDidTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
