//
//  Model.swift
//  MinischoolOne
//
//  Created by JONGYOUNG CHUNG on 06/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation
import WebRTC

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

//SessionDescription

//IceCandidate

public struct AVConstraint: Codable{
    
    init(){
        self.audio = false
        self.video = false
    }
    
    var audio: Bool
    var video: Bool
}

public struct ICEConfiguration: Codable{
    
    /*
     const configuration = {
     iceServers: [{
     //url: 'stun:stun.l.google.com:19302',
     url: "stun:stage-ct-e1.minischool.co.kr:3478",
     urls: "stun:stage-ct-e1.minischool.co.kr:3478"
     }, {
     credential: "********",
     url: "turn:stage-ct-e1.minischool.co.kr:3478?transport=udp",
     urls: "turn:stage-ct-e1.minischool.co.kr:3478?transport=udp",
     username: "minischool"
     }]
     };
     */
    init() {
        self.iceServers = []
    }
    
    var iceServers: [Url]
}

public struct Url: Codable{
    var credential: String
    var url: String
    var urls: String
    var username: String
}

