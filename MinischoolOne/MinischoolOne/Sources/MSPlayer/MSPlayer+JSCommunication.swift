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
        DLog.printLog("JSToNative function: \(function)")
        
        let parameterData: Any? = dictionary["data"]
        if let json = parameterData {
            DLog.printLog("JSToNative parameter: \(json)")
        }else{
            printError("\(function) has no parameter")
        }
        
        let jsonData = ["function" : function, "parameter" : parameterData]
        self.callBackLog(payload: jsonData as [String : Any])
        
        switch function {
            
        case "startWebRTC" :
            if let webRTCParameter : WebRTCParameter = self.jsonTo(json: parameterData) {
                self.startWebRTC(webRTCParameter)
            }
            
        case "stopWebRTC" :
            self.stopWebRTC()
            
        case "createLocalVideo" :
            if let frame: Frame = self.jsonTo(json: parameterData as? String) {
                self.createLocalVideo(frame)
            }
            
        case "destroyLocalVideo" :
            self.hideVideo(isLocal: true)
            
        case "createRemoteVideo" :
            if let frame: Frame = self.jsonTo(json: parameterData as? String) {
                self.createRemoteVideo(frame)
            }
            
        case "destroyRemoteVideo" :
            self.hideVideo(isLocal: false)
            
        case "onReceiveOffer" :
            if let sdp: SessionDescription = self.jsonTo(json: parameterData as? String) {
                self.onReceiveOffer(sdp)
            }
            
        case "onReceiveAnswer" :
            if let sdp: SessionDescription = self.jsonTo(json: parameterData as? String) {
                self.onReceiveAnswer(sdp)
            }
            
        case "onReceiveIceCandidate" :
            if let candidate: IceCandidate = self.jsonTo(json: parameterData as? String) {
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
            
        case "onWait" : //수업 룸에 참여하여 교사를 기다리는 중
            self.changeStatusTo(MSPlayerStatus.waiting)
            
        case "onStarted" : //교사와 연결되어 수업을 진행
            self.unmuteAudio()
            self.changeStatusTo(MSPlayerStatus.started)
            
        case "onEnded" : //수업이 종료됨
            self.changeStatusTo(MSPlayerStatus.ended)
            self.stopWebRTC()
            
        case "onError" : //에러가 발생
            self.deliverError(parameterData.debugDescription)
            
        case "changeStatusTo" :
            if let status: MSPlayerStatus = self.jsonTo(json: parameterData as? String) {
                self.changeStatusTo(status)
            }
            
        case "backLoggingOn" :
            self.backLoggingOn = true
            
        case "backLoggingOff" :
            self.backLoggingOn = false
            
        case "loadResource" :
            
            if let resourceList: ResourceList = self.jsonTo(json: parameterData as? String) {
                DLog.printLog("Resources: \(parameterData ?? "")")
                self.loadResources(resources: resourceList.resourceList)
            }
            
        case "createVideo" :
            if let frame: MovieClipFrame = self.jsonTo(json: parameterData as? String) {
                self.createMovieClip(frame: frame)
            }
            
        case "destroyVideo" :
            if let base: Base = self.jsonTo(json: parameterData as? String) {
                self.destoryMovieClip(id: base.id)
            }
            
        case "createBGImage" :
            if let base: Base = self.jsonTo(json: parameterData as? String) {
                self.setBackground(base.id)
            }
            
        case "destroyBGImage" :
            self.removeBackground()
            
        case "onLoadPageStart" :
            self.onLoadPageStart()
            
        case "onLoadPageEnd" :
            self.onLoadPageEnd()
            
        case "goBack" :
            self.stopWebRTC()
            self.closeAll()
            
        case "playSound":
            if let base: Base = jsonTo(json: parameterData as? String) {
                playSoundEffect(base.id, options: base.options)
            }
            
        case "playCameraSound":
            playCameraEffectSound()
            
        case "stopSound":
            if let base: Base = jsonTo(json: parameterData as? String) {
                stopSoundEffect(base.id)
            }
            
        case "stopSoundAll":
            stopAllSoundEffect()
            
        default:
            printError("\(function) is not defined in ios native", sendNativeError: false)
        }
    }
    
    func jsonToArray<T: Codable>(json: Any?) -> [T]? {
        do {
            return try JSONDecoder().decode([T].self, from: (json as! String).data(using: .utf8)!)
        } catch let parsingError {
            printError("Parsing error: \(parsingError)")
        }
        return nil
    }
    
    func jsonTo<T: Codable>(json: Any?) -> T? {
        
        do {
            return try JSONDecoder().decode(T.self, from: (json as! String).data(using: .utf8)!)
        } catch let parsingError {
            printError("Parsing error: \(parsingError)")
        }
        return nil
    }
    
    func jsonFrom<T: Codable>(obj: T) -> String? {
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(obj)
            return String(data: data, encoding: .utf8)
        } catch let parsingError {
            printError("Encoding error: \(parsingError)")
        }
        return nil
    }
    
    func printError(_ message : String, sendNativeError isSend: Bool) {
        //call JS function to send error to Player(web)
        if isSend {
            sendNativeError(message)
        }
        
        let errorMessage = "Native Framwork Error: \(message)"
        deliverError(errorMessage)
    }
    
    func printError(_ message : String) {
        printError(message, sendNativeError: true)
    }
    
    //    WebRTC Control
    public func startWebRTC(_ webRTCParameter : WebRTCParameter) {
        DLog.printLog("startWebRTC")
        Client.prepare(webRTCParameter : webRTCParameter)
        Client.shared.webRTCClient.delegate = self
    }
    
    public func stopWebRTC() {
        DLog.printLog("stopWebRTC")
        if let webRTCClient = Client.shared?.webRTCClient {
            stopAllSoundEffect()
            soundEffectLayers.removeAll()
            webRTCClient.stopRenderRemoteVideo()
            self.hideVideo(isLocal: false)
            webRTCClient.stopCaptureLocalVideo()
            self.hideVideo(isLocal: true)
            webRTCClient.closePeerConnection()
        } else {
            printError("webRTCClient is not ready, nothing to stop")
        }
    }
    
    //    Video Control
    public func createLocalVideo(_ frame: Frame) {
        self.createCaptureVideo(isLocal: true, frame: frame)
    }
    
    public func createRemoteVideo(_ frame: Frame) {
        self.createCaptureVideo(isLocal: false, frame: frame)
    }
    
    public func destroyLocalVideo() {
        self.destroyVideo(isLocal: true)
    }
    
    public func destroyRemoteVideo() {
        self.destroyVideo(isLocal: false)
    }
    
    //    WebRTC Callback
    public func  onReceiveOffer(_ sdp: SessionDescription) {
        Client.shared.webRTCClient.set(remoteSdp: sdp.rtcSessionDescription) { (err) in
            if let error = err {
                DLog.printLog("webRTCClient.set has error!!!")
                self.printError(error.localizedDescription)
                return
            }
            
            Client.shared.webRTCClient.answer { (localSdp) in
                self.sendAnswer(SessionDescription(from: localSdp))
            }
        }
    }
    
    public func  onReceiveAnswer(_ sdp: SessionDescription) {
        printError("onReceiveAnswer has not been implemented")
    }
    
    public func  onReceiveIceCandidate(_ candidate: IceCandidate) {
        Client.shared.webRTCClient.set(remoteCandidate: candidate.rtcIceCandidate)
    }
    
    //    NativeToJS
    public func  sendOffer(_ sdp: SessionDescription) {
        let json = jsonFrom(obj: sdp)
        self.callJS(jsFunctionName: "NativeToJS.sendOffer", data: "\(json!)")
    }
    
    public func  sendAnswer(_ sdp: SessionDescription) {
        let json = jsonFrom(obj: sdp)
        self.callJS(jsFunctionName: "NativeToJS.sendAnswer", data: "\(json!)")
    }
    
    public func  sendIceCandidate(_ candidate: IceCandidate) {
        let json = jsonFrom(obj: candidate)
        self.callJS(jsFunctionName: "NativeToJS.sendIceCandidate", data: "\(json!)")
    }
    
    public func  loadResourceDone() {
        DLog.printLog("loadResourceDone")
        self.callJS(jsFunctionName: "NativeToJS.loadResourceDone", data: "")
    }
    
    public func sendNativeError(_ message : String) {
        let json = jsonFrom(obj: message)
        self.callJS(jsFunctionName: "NativeToJS.sendNativeError", data: "\(json!)")
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
    
    public func onLoadPageStart() {
        DLog.printLog("onLoadPageStart")
        self.removeBackground()
    }
    
    public func onLoadPageEnd() {
        DLog.printLog("onLoadPageEnd")
    }
    
    public func changeStatusTo(_ status: MSPlayerStatus) {
        self.delegate?.MSPlayer(self, didChangedStatus: status)
    }
    
    public func deliverError(_ message: String) {
        
        let error = MSPlayerError.runtimeError(message)
        self.delegate?.MSPlayer(self, errorOccured: error)
    }
    
    enum MSPlayerError: Error {
        case runtimeError(String)
    }
    
    public func openUrl(_ urlString: String) {
        if self.useWKWebview {
            self.openUrlWK(urlString)
        }
    }
    
    public func callJS(jsFunctionName: String, data: String) {
        if self.useWKWebview {
            self.callJSWK(jsFunctionName: jsFunctionName, data: data)
        }
    }
    
    public func generateLog() -> [String: Any] {
        var logs = [String: Any]()
        logs["serviceAppVersion"] = serviceAppVersion
        logs["frameworkVersion"] = frameworkVersion
        
        //speaker status
        var speakerLogs = [String: Any]()
        speakerLogs["status"] = Utils.speakerStatus
        speakerLogs["volume"] = Utils.volumeOfSpeaker
        
        //internet connection status
        var connectionLogs = [String: Any]()
        connectionLogs["status"] = Reachability.shared.isConnectedToNetwork() ? "Connected" : "Not Connected"
        connectionLogs["type"] = Reachability.shared.getConnectionType()
        
        //generate device info
        var deviceLogs = [String: Any]()
        deviceLogs["name"] = Utils.deviceName
        deviceLogs["os"] = Utils.deviceOS
        deviceLogs["model"] = Utils.deviceModel
        deviceLogs["camera_status"] = Utils.cameraStatus
        deviceLogs["microphone_status"] = Utils.microPhoneStatus
        deviceLogs["speaker"] = speakerLogs
        deviceLogs["network"] = connectionLogs
        
        logs["deviceInfo"] = deviceLogs
        
        return logs
    }
}
