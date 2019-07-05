//
//  Client.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 03/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation

class Client {
    
    static let shared = Client()
    
    public var signalClient: SignalingClient!
    public var webRTCClient: WebRTCClient!
    
    private init() {
        
        let config = Config.default
        self.signalClient = SignalingClient(serverUrl: config.signalingServerUrl)
        self.webRTCClient = WebRTCClient(iceServers: config.webRTCIceServers)
    }
}
