//
//  ViewController.swift
//  Minischool-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import UIKit
import MinischoolOne

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    var player: MSPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = MSPlayer(self.containerView, viewController: self)
        self.player.run()
    }

    @IBAction func tapRun(_ sender: Any) {
    }
    
}

