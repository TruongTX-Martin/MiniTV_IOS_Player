//
//  ViewController.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import UIKit
import MinischoolOne

class ViewController: UIViewController, MSPlayerDelegate {
    func MSPlayer(_ player: MSPlayer, didChangedStatus newStatus: MSPlayerStatus) {
        switch newStatus {
        case .waiting:
            print("waiting")
        case .started:
            print("started")
        case .ended:
            print("ended")
        default:
            print("errorOcccured")
        }
    }

    @IBOutlet weak var containerView: UIView!
    var player: MSPlayer!
    
    //https://stage-p2.minischool.co.kr/preview/Y2sxNTYxOTY2MjMxMjY1e4a0a4be-4924-4557-a28a-025ade7451b1?ref=a

    let serviceAppVersion = "1.0"
    let url = "http://172.16.3.95:8080"
//    let url = "https://stage-p2.minischool.co.kr/preview/"
    let classKey = "Y2sxNTYxOTY2MjMxMjY"
    let token = "1e4a0a4be-4924-4557-a28a-025ade7451b1"
    let role = "s"
    // 클래스 룸
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = MinischoolOne.MSPlayer(self.view, viewController: self, serviceAppVersion: serviceAppVersion, url: url, classKey: classKey, token: token, role: role)
        
        self.player.delegate = self
        
        self.player.run()
    }

    @IBAction func tapRun(_ sender: Any) {
    }
    
}

