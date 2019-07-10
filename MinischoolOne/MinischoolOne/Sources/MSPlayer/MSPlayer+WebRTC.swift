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
        //offer하고 상대를 찾음
        print("discovered local candidate")
//        self.localCandidateCount += 1
        Client.shared.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
//        let textColor: UIColor
//        switch state {
//        case .connected, .completed:
//            textColor = .green
//        case .disconnected:
//            textColor = .orange
//        case .failed, .closed:
//            textColor = .red
//        case .new, .checking, .count:
//            textColor = .black
//        @unknown default:
//            textColor = .black
//        }
        DispatchQueue.main.async {
//            self.webRTCStatusLabel?.text = state.description.capitalized
//            self.webRTCStatusLabel?.textColor = textColor
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
        }
    }
    
//    JSToNative
    
//    WebRTC Control
    public func startWebRTC( constraints: AVConstraint, iceConfiguration: ICEConfiguration ) {
        Client.constraints = constraints
        Client.iceConfiguration = iceConfiguration
    
    }
    
    public func stopWebRTC() {
        
    }
    
//    Video Control
    public func createLocalVideo(_ frame: Frame) {
        self.createVideo(isLocal: true, frame: frame)
        if frame.z == 0 {
            self.bringLocalVideoToFront()
        }else{
            self.sendLocalVideoToBack()
        }
    }
    
    public func createRemoteVideo(_ frame: Frame) {
        self.createVideo(isLocal: false, frame: frame)
        if frame.z == 0 {
            self.bringRemoteVideoToFront()
        }else{
            self.sendRemoteVideoToBack()
        }
    }

    public func destroyLocalVideo() {
        self.destroyVideo(isLocal: true)
    }
    
    public func destroyRemoteVideo() {
        self.destroyVideo(isLocal: false)
    }
    
//    WebRTC Callback
    public func  onReceiveOffer(_ sdp: SDP) {
        
    }
    public func  onReceiveAnswer(_ sdp: SDP) {
        
    }
    public func  onReceiveIceCandidate(_ candidate: Candidate) {
        
    }
//    NativeToJS
    public func  sendOffer(_ sdp: String) {
        
    }
    public func  sendAnswer(_ sdp: String) {
        
    }
    public func  sendIceCandidate(_ sdp: String) {
        
    }
}
