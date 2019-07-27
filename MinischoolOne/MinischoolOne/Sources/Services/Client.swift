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
    
    var webRTCClient: WebRTCClient!

    public init(webRTCParameter : WebRTCParameter) {
    
        self.webRTCClient = WebRTCClient(webRTCParameter)
    }
    
    public static func prepare(webRTCParameter : WebRTCParameter) {
        print("Client prepare")
        Client.shared = Client(webRTCParameter: webRTCParameter)
    }
}
