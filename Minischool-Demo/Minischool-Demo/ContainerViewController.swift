//
//  ViewController.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import UIKit
import MinischoolOne

class ContainerViewController: UIViewController, MSPlayerDelegate {

    var player: MSPlayer!
    @IBOutlet weak var goButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.isTranslucent = true
            nav.view.backgroundColor = .clear
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        let serviceAppVersion = "1.0"
        let role = ""
        
        let url = UserDefaults.standard.string(forKey: "url") ?? ""
        
        print("ContainerViewController url: \(url)")

        if url != "" {
            
            self.player = MinischoolOne.MSPlayer(self.view, viewController: self, serviceAppVersion: serviceAppVersion, url: url)

        }else{

            let segmentedServer = UserDefaults.standard.integer(forKey: "segmentedServer")
            let segmentedToken = UserDefaults.standard.integer(forKey: "segmentedToken")

            let server1 = UserDefaults.standard.string(forKey: "server1") ?? ""
            let server2 = UserDefaults.standard.string(forKey: "server2") ?? ""
            let classKeyAndToken1 = UserDefaults.standard.string(forKey: "classKeyAndToken") ?? ""
            let classKeyAndToken2 = UserDefaults.standard.string(forKey: "classKeyAndToken2") ?? ""

            let server = segmentedServer == 0 ? server1 : server2
            let classKeyAndToken = segmentedToken == 0 ? classKeyAndToken1 : classKeyAndToken2
            let serverAddress = "\(server)"

            self.player = MinischoolOne.MSPlayer(self.view, viewController: self, serviceAppVersion: serviceAppVersion, serverAddress: serverAddress, classKeyAndToken: classKeyAndToken, role: role)
        }
        self.player.delegate = self
        
        self.player.run()
        
        //self.view.bringSubviewToFront(self.goButton)
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        print("didEnterBackground")
        self.player.closeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
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
    
    @IBAction func tapGo(_ sender: Any) {
//        self.player.speakerForceOn()
    }
}

