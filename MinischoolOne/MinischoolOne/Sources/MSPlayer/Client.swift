//
//  Client.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 03/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation

public class Client {
    
    static var shared : Client!
    
//    var signalClient: SignalingClient!
    var webRTCClient: WebRTCClient!

    /*
    private init() {
        
        let config = Config.default
        self.signalClient = SignalingClient(serverUrl: config.signalingServerUrl)
        self.webRTCClient = WebRTCClient(iceServers: config.webRTCIceServers)
    }
     */
    
    public init(iceConfiguration: ICEConfiguration, constraints: AVConstraint) {
    
        self.webRTCClient = WebRTCClient(iceConfiguration: iceConfiguration, constraints: constraints)
    }
    
    public static func prepare(iceConfiguration: ICEConfiguration, constraints: AVConstraint) {
        Client.shared = Client(iceConfiguration: iceConfiguration, constraints: constraints)
    }
}
