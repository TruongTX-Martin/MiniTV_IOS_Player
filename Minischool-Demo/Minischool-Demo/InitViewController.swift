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

    @IBOutlet weak var segmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.server1.text = UserDefaults.standard.string(forKey: "server1") ?? "172.16.3.95:8080"
        self.server2.text = UserDefaults.standard.string(forKey: "server2") ?? "172.16.3.95:8080"
        self.classKeyAndToken.text = UserDefaults.standard.string(forKey: "classKeyAndToken") ?? "Y2sxNTYzMjU4NDQ3MTAydG9rZW4xMDE1NjE2OTA2Nzg5NDM="
        self.segmented.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "segmented")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

    }
    
    @IBAction func tapGo(_ sender: Any) {
        UserDefaults.standard.set(self.server1.text, forKey: "server1")
        UserDefaults.standard.set(self.server2.text, forKey: "server2")
        UserDefaults.standard.set(self.classKeyAndToken.text, forKey: "classKeyAndToken")
        UserDefaults.standard.set(self.segmented.selectedSegmentIndex, forKey: "segmented")
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

