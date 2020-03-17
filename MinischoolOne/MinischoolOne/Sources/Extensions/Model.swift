//
//  Model.swift
//  MinischoolOne
//
//  Created by JONGYOUNG CHUNG on 06/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation
import WebRTC

public struct Frame: Codable {
    
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var zIndex: CGFloat = 0.0
    var canvasOver: Bool = true
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
    
    var iceServers: [Url]
}

public struct ResourceList: Codable{
    
    var resourceList: [Resource]
}

public struct Resource: Codable{
    
    var id: Int
    var src: String
    var assetType:AssetType
}

public enum AssetType: String, Codable {
    case image
    case sound
    case video
}
public struct MovieClipFrame: Codable{
    
    var id: Int = 0
    
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var zIndex: CGFloat = 0.0
    var canvasOver: Bool = true
}


public struct Base: Codable{
    
    var id: Int
}

public struct Url: Codable{
    var credential: String?
    var url: String
    var urls: String
    var username: String?
}

@objc
public enum MSPlayerStatus: Int, Codable {
    case waiting = 100
    case started = 200
    case ended = 300
    case closed = 400
    case errorOcccured = 900
}

public enum ZINDEX: CGFloat {
    case Background = 10000.0
    case Canvas = 2000.0
}

public enum NativeError: Int {
    case JSON_PARSE_ERROR = 0
    case NO_VIDEO_ID = 1
}
