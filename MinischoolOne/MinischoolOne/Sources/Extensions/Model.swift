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
    
    var x: CGFloat
    var y: CGFloat
    var zIndex: CGFloat
    var width: CGFloat
    var height: CGFloat
}

public struct WebRTCParameter: Codable{
    
    var constraints: AVConstraint
    var iceConfiguration: ICEConfiguration
}

public struct AVConstraint: Codable{
    
    var audio: Bool
    var video: [String: [String: Int]]
}

public struct ICEConfiguration: Codable{
    
    init() {
        self.iceServers = []
    }
    
    var iceServers: [Url]
}

public struct Url: Codable{
    var credential: String?
    var url: String
    var urls: String
    var username: String?
}

public enum MSPlayerStatus: Int, Codable {
    case waiting = 100
    case started = 200
    case ended = 300
    case errorOcccured = 900
}
