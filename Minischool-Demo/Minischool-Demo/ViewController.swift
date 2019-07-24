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

//    @IBOutlet weak var containerView: UIView!
    var player: MSPlayer!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let segmentedServer = UserDefaults.standard.integer(forKey: "segmentedServer")
        let segmentedToken = UserDefaults.standard.integer(forKey: "segmentedToken")

        let server1 = UserDefaults.standard.string(forKey: "server1") ?? ""
        let server2 = UserDefaults.standard.string(forKey: "server2") ?? ""
        let classKeyAndToken1 = UserDefaults.standard.string(forKey: "classKeyAndToken") ?? ""
        let classKeyAndToken2 = UserDefaults.standard.string(forKey: "classKeyAndToken2") ?? ""

        let server = segmentedServer == 0 ? server1 : server2
        let classKeyAndToken = segmentedToken == 0 ? classKeyAndToken1 : classKeyAndToken2
        let url = "http://\(server)"

        let serviceAppVersion = "1.0"
        let role = "s"

        self.player = MinischoolOne.MSPlayer(self.view, viewController: self, serviceAppVersion: serviceAppVersion, url: url, classKeyAndToken: classKeyAndToken, role: role)
        
        self.player.delegate = self
        
        self.player.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.player.closeAll()
    }

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
    
    func MSPlayer(_ player: MSPlayer, errorOccured error: Error) {
        print(error.localizedDescription)
    }
}

