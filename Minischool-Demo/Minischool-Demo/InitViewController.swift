//
//  InitViewController.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 22/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import UIKit
import MinischoolOne

class InitViewController: UIViewController {
    
    @IBOutlet weak var server1: UITextField!
    @IBOutlet weak var server2: UITextField!
    @IBOutlet weak var classKeyAndToken: UITextField!
    @IBOutlet weak var classKeyAndToken2: UITextField!

    @IBOutlet weak var segmentedServer: UISegmentedControl!
    @IBOutlet weak var segmentedToken: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.isTranslucent = true
            nav.view.backgroundColor = .clear
        }
        
        self.server1.text = UserDefaults.standard.string(forKey: "server1") ?? "172.16.3.95:8080"
        self.server2.text = UserDefaults.standard.string(forKey: "server2") ?? "172.16.3.95:8080"
        self.classKeyAndToken.text = UserDefaults.standard.string(forKey: "classKeyAndToken") ?? "Y2sxNTYzMjU4NDQ3MTAydG9rZW4xMDE1NjE2OTA2Nzg5NDM="
        self.classKeyAndToken2.text = UserDefaults.standard.string(forKey: "classKeyAndToken2") ?? ""
        self.segmentedServer.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "segmentedServer")
        self.segmentedToken.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "segmentedToken")

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func tapGo(_ sender: Any) {
        UserDefaults.standard.set(self.server1.text, forKey: "server1")
        UserDefaults.standard.set(self.server2.text, forKey: "server2")
        UserDefaults.standard.set(self.classKeyAndToken.text, forKey: "classKeyAndToken")
        UserDefaults.standard.set(self.classKeyAndToken2.text, forKey: "classKeyAndToken2")
        UserDefaults.standard.set(self.segmentedServer.selectedSegmentIndex, forKey: "segmentedServer")
        UserDefaults.standard.set(self.segmentedToken.selectedSegmentIndex, forKey: "segmentedToken")
        UserDefaults.standard.set("", forKey: "url")
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

