//
//  Model.swift
//  MinischoolOne
//
//  Created by JONGYOUNG CHUNG on 06/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation

public struct Frame: Codable{
    
    init() {
        self.x = 0
        self.y = 0
        self.z = 0
        self.width = 100
        self.height = 100
    }
    
    init(x: CGFloat, y: CGFloat, z: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
        self.width = width
        self.height = height
    }
    
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
    var width: CGFloat
    var height: CGFloat
}

struct SDP: Codable{

}
