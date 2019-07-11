//
//  MSPlayer+JSCommunication.swift
//  MinischoolOne
//
//  Created by JONGYOUNG CHUNG on 10/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation
import WebRTC

extension MSPlayer {
    
    public func JSToNative(dictionary: [String: Any]) {
        
        guard let function = dictionary["function"] as? String else { return }
        print(function)
        
        let json: Any? = dictionary["data"]
        if let json = json {
            print(type(of: json))
            print(json)
        }
        
        switch function {
            
            case "startWebRTC" :
                print("startWebRTC start")
                if let webRTCParameter : WebRTCParameter = self.jsonTo(json: json) {
                    print("webRTCParameter")
                    print(webRTCParameter)
                    self.startWebRTC(webRTCParameter)
                }
            
            case "stopWebRTC" :
                self.stopWebRTC()
            
            case "createLocalVideo" :
                if let frame: Frame = self.jsonTo(json: json as? String) {
                    self.createLocalVideo(frame)
                }
            
            case "destroyLocalVideo" :
                self.destroyLocalVideo()
            
            case "createRemoteVideo" :
                if let frame: Frame = self.jsonTo(json: json as? String) {
                    self.createRemoteVideo(frame)
                }
            
            case "destroyRemoteVideo" :
                self.destroyRemoteVideo()
            
            case "onReceiveOffer" :
                if let sdp: SessionDescription = self.jsonTo(json: json as? String) {
                    self.onReceiveOffer(sdp)
                }
            
            case "onReceiveAnswer" :
                if let sdp: SessionDescription = self.jsonTo(json: json as? String) {
                    self.onReceiveAnswer(sdp)
                }
            
            case "onReceiveIceCandidate" :
                if let candidate: IceCandidate = self.jsonTo(json: json as? String) {
                    self.onReceiveIceCandidate(candidate)
                }

            case "muteAudio" :
                self.muteAudio()
            
            case "unmuteAudio" :
                self.unmuteAudio()
            
            case "speakerOn" :
                self.speakerOn()
            
            case "speakerOff" :
                self.speakerOff()
            
            default:
                printError("\(function) is not defined in ios native")
        }
    }
    
    func jsonTo<T: Codable>(json: Any?) -> T? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: (json as! String).data(using: .utf8)!)
        } catch let parsingError {
            printError("Parsing error: \(parsingError)")
        }
        return nil
    }
    
    func printError(_ message : String) {
        print(message)
        self.callJS(jsFunctionName: "console.log", data: "\(message)")
    }
    
    //    JSToNative
    
    //    WebRTC Control
    public func startWebRTC(_ webRTCParameter : WebRTCParameter) {
        Client.prepare(webRTCParameter : webRTCParameter)
    }
    
    public func stopWebRTC() {
        
    }
    
    //    Video Control
    public func createLocalVideo(_ frame: Frame) {
        self.createVideo(isLocal: true, frame: frame)
    }
    
    public func createRemoteVideo(_ frame: Frame) {
        self.createVideo(isLocal: false, frame: frame)
    }
    
    public func destroyLocalVideo() {
        self.destroyVideo(isLocal: true)
    }
    
    public func destroyRemoteVideo() {
        self.destroyVideo(isLocal: false)
    }
    
    //    WebRTC Callback
    public func  onReceiveOffer(_ sdp: SessionDescription) {
        
    }
    public func  onReceiveAnswer(_ sdp: SessionDescription) {
        
    }
    public func  onReceiveIceCandidate(_ candidate: IceCandidate) {
        
    }
    //    NativeToJS
    public func  sendOffer(_ sdp: SessionDescription) {
        self.callJS(jsFunctionName: "sendOffer", data: "\(sdp)")
    }
    public func  sendAnswer(_ sdp: SessionDescription) {
        self.callJS(jsFunctionName: "sendAnswer", data: "\(sdp)")
    }
    public func  sendIceCandidate(_ candidate: IceCandidate) {
        self.callJS(jsFunctionName: "sendIceCandidate", data: "\(candidate)")
    }
    
    public func muteAudio() {
        Client.shared.webRTCClient.muteAudio()
    }
    
    public func unmuteAudio() {
        Client.shared.webRTCClient.unmuteAudio()
    }
    
    public func speakerOff() {
        Client.shared.webRTCClient.speakerOff()
    }
    
    public func speakerOn() {
        Client.shared.webRTCClient.speakerOn()
    }
}
