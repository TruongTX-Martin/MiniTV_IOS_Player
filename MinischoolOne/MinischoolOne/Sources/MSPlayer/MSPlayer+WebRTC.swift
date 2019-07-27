//
//  MSPlayer+WebRTC.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation
import WebRTC

extension MSPlayer: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.sendIceCandidate(IceCandidate(from: candidate))
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {

    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {

    }
    
    func initWebRTC() {
        print("initWebRTC")
        let url1 = Url(credential: nil, url: "stun:stage-ct-e1.minischool.co.kr:3478", urls: "stun:stage-ct-e1.minischool.co.kr:3478", username: nil)
        let url2 = Url(credential: "kmskms1!", url: "turn:stage-ct-e1.minischool.co.kr:3478?transport=udp", urls: "turn:stage-ct-e1.minischool.co.kr:3478?transport=udp", username: "minischool")
        
        let iceConfiguration = ICEConfiguration(iceServers: [url1, url2])
        
        let videoConst =
                   [ "mandatory": [
                        "minWidth": 160,
                        "maxWidth": 160,
                        "minHeight": 120,
                        "maxHeight": 120,
                        "maxFrameRate": 10
                    ]
                ]
        
        let avConst = AVConstraint(audio: true, video: videoConst)
        let webRTCParameter = WebRTCParameter(constraints: avConst, iceConfiguration: iceConfiguration)

        self.startWebRTC(webRTCParameter)
    }
}
