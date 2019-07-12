//
//  Config.swift
//  WebRTC-Demo
//
//  Created by Stasel on 30/01/2019.
//  Copyright © 2019 Stasel. All rights reserved.
//

import Foundation

// Set this to the machine's address which runs the signaling server
fileprivate let defaultSignalingServerUrl = URL(string: "ws://127.0.0.1:8080")!

// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
fileprivate let defaultIceServers1 = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]
fileprivate let defaultIceServers = ["stun:stage-ct-e1.minischool.co.kr:3478",
                                     "turn:stage-ct-e1.minischool.co.kr:3478?transport=udp"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}
