//
//  Loading.swift
//  msplayer_ios
//
//  Created by neo on 14/06/2019.
//  Copyright © 2019 neo. All rights reserved.
//

import Foundation
import SpriteKit

class LoadingScene: SKScene {
    
    var scoreLabel: SKLabelNode!
    
//    override init() {
//        super.init(size: CGSize.zero)
//        //self.backgroundColor = .blue
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundColor = .red
        print("didMove")

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 0, y: 0)
        addChild(scoreLabel)
        

    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        print("sceneDidLoad")
    }
    
    

}
