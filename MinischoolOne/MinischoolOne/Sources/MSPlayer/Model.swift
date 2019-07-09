//
//  Model.swift
//  MinischoolOne
//
//  Created by JONGYOUNG CHUNG on 06/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation

struct Frame: Codable{
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
