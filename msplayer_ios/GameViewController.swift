//
//  GameViewController.swift
//  msplayer_ios
//
//  Created by neo on 12/06/2019.
//  Copyright © 2019 neo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    
    override func viewDidLoad() {
        
        self.view.backgroundColor = .yellow

        let sView = SKView(frame: self.view.frame)
        sView.backgroundColor = .clear
        sView.allowsTransparency = true
       
        
        let loadingScene = LoadingScene()
        
        sView.presentScene(loadingScene)
        self.view.addSubview(sView)


        
        findBookInfo { (isSuccess, book) in
            guard isSuccess else {
                print("error")
                return
            }
            
            print("success  \(book!.pageGroups[0].pages[0])")
        }
        
        
        //let scene = GameScene()
        //scene.backgroundColor = .clear

        //self.view.addSubview(sView)
        
        //        let cameraView = CameraView(frame: self.view.frame)
        //        self.view.addSubview(cameraView)
        //

        //        let scene = GameScene(size: view.frame.size)
//        let skView = view as! SKView
//        skView.presentScene(scene)
    }


}
