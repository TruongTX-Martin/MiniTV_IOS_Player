//
//  MSPlayer+Delegate.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation
import WebRTC

extension MSPlayer: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        print("signalClientDidConnect")
//        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("signalClientDidDisconnect")
//        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        //SDP란 Session Description Protocol 의 약자로 연결하고자 하는 Peer 서로간의 미디어와 네트워크에 관한 정보를 이해하기 위해 사용된다.
        Client.shared.webRTCClient.set(remoteSdp: sdp) { (error) in
//            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("오퍼 받음 Received remote candidate")
//        self.remoteCandidateCount += 1
        Client.shared.webRTCClient.set(remoteCandidate: candidate)
    }
    
}
