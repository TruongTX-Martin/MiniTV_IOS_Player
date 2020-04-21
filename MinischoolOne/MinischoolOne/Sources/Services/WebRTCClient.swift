//
//  WebRTCClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: class {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

final class WebRTCClient: NSObject {
    
    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    private let peerConnection: RTCPeerConnection
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]    
    private var videoCapturer: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    private weak var localRenderer: RTCVideoRenderer?
    private weak var remoteRenderer: RTCVideoRenderer?
    
    private var localVideoMandatory: [String: Int]?
    
    public var videoCaptureFormat: AVCaptureDevice.Format?

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    required init(_ webRTCParameter : WebRTCParameter) {

        let iceConfiguration = webRTCParameter.iceConfiguration
        let constraints = webRTCParameter.constraints
        
        self.localVideoMandatory = constraints.video["mandatory"]
        
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: iceConfiguration.iceServers.map({ (url) -> String in
            return url.urls
        }), username:  iceConfiguration.iceServers.first(where: { (url) -> Bool in
            return url.username != nil
        })?.username, credential: iceConfiguration.iceServers.first(where: { (url) -> Bool in
            return url.credential != nil
        })?.credential )]
        // Unified plan is more superior than planB
        config.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        
        let mandatoryConstraints = [kRTCMediaConstraintsOfferToReceiveAudio: constraints.audio ? kRTCMediaConstraintsValueTrue : kRTCMediaConstraintsValueFalse,
                                            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
        let rTCMediaConstraints = RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])

        self.peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: rTCMediaConstraints, delegate: nil)

        super.init()
        self.createMediaSenders()
        self.configureAudioSession()
        self.peerConnection.delegate = self
        
        self.rtcAudioSession.add(self)
        
        registerOrientationObserver()
        forceDeviceOrientationIfNeeded()
        self.startCapture()
    }
    
    // MARK: Signaling
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        self.peerConnection.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void)  {
        DLog.printLog("webRTCClient.answer")
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        self.peerConnection.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
//        DLog.printLog("set remoteSdp: \(remoteSdp)")
        self.peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate) {
        self.peerConnection.add(remoteCandidate)
    }
    
    // MARK: Media
//    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
    func startCapture() {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else { return }

        guard let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }) else { return }
        
        let maxFrameRate = self.localVideoMandatory?["maxFrameRate"] ?? 10
        let maxWidth = self.localVideoMandatory?["maxWidth"] ?? 320
        let maxHeight = self.localVideoMandatory?["maxHeight"] ?? 240
        
        // 포맷 설정
        let targetWidth = Int32( maxWidth )
        let targetHeight = Int32( maxHeight )
//        var selectedFormat:AVCaptureDevice.Format?
        var currentDiff = INT_MAX
        
        let formats = RTCCameraVideoCapturer.supportedFormats(for: frontCamera )
        //최대한 타겟과 비슷한 프리셋 찾기
        for format in formats {
            let dimension:CMVideoDimensions = CMVideoFormatDescriptionGetDimensions( format.formatDescription )
            let pixelFormat:FourCharCode = CMFormatDescriptionGetMediaSubType( format.formatDescription )
            let diff = abs(targetWidth - dimension.width) + abs( targetHeight - dimension.height)
            if( diff < currentDiff ) {
                self.videoCaptureFormat = format
                currentDiff = diff
            } else if( diff == currentDiff && pixelFormat == capturer.preferredOutputPixelFormat()) {
                self.videoCaptureFormat = format
            }
        }
        guard let targetFormat = self.videoCaptureFormat else { return }
        
        DLog.printLog("targetFormat: \(targetFormat.formatDescription)")
        
        capturer.startCapture(with: frontCamera, format: targetFormat, fps: maxFrameRate)
    }
    
    func startLocalVideo(renderer: RTCVideoRenderer) {
        self.localVideoTrack?.add(renderer)
        self.localRenderer = renderer
    }
    
    func stopCaptureLocalVideo() {
        guard let renderer = self.localRenderer else { return }
        self.localVideoTrack?.remove(renderer)
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }
        capturer.stopCapture()
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
        self.remoteRenderer = renderer
    }
    
    func stopRenderRemoteVideo() {
        guard let renderer = self.remoteRenderer else { return }
        self.remoteVideoTrack?.remove(renderer)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setActive(true)
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: .mixWithOthers)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.default.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack0 = self.createAudioTrack("audio0")
        self.peerConnection.add(audioTrack0, streamIds: [streamId])

        let audioTrack1 = self.createAudioTrack("audio1")
        self.peerConnection.add(audioTrack1, streamIds: [streamId])

        // Video
        let videoTrack = self.createVideoTrack()
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        // No Data in native part
    }
    
    private func createAudioTrack(_ trackId: String) -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: trackId)
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        
        #if TARGET_OS_SIMULATOR
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    func closePeerConnection() {
        self.peerConnection.close()
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream : \(stream.debugDescription)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remote stream : \(stream.debugDescription)")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
        if newState == RTCIceConnectionState.connected {
            self.muteAudio()
            //self.speakerOn()
//            self.speakerForceOn()
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}

extension WebRTCClient: RTCAudioSessionDelegate {
    func audioSessionDidBeginInterruption(_ session: RTCAudioSession) {
        DLog.printLog("RTCAudioSessionDelegate-audioSessionDidBeginInterruption")
    }
    func audioSessionDidEndInterruption(_ session: RTCAudioSession, shouldResumeSession: Bool) {
        DLog.printLog("RTCAudioSessionDelegate-audioSessionDidEndInterruption")
    }
    func audioSessionDidChangeRoute(_ session: RTCAudioSession, reason: AVAudioSession.RouteChangeReason, previousRoute: AVAudioSessionRouteDescription) {
        DLog.printLog("RTCAudioSessionDelegate-audioSessionDidChangeRoute reason: \(self.getReasonString(reason: reason))")
        for (prev, curr) in zip(previousRoute.inputs, session.currentRoute.inputs) {
            printIfNotEqual("input", s1: prev.portName, s2: curr.portName)
        }
        for (prev, curr) in zip(previousRoute.outputs, session.currentRoute.outputs) {
            printIfNotEqual("outputs", s1: prev.portName, s2: curr.portName)
        }
        DLog.printLog(self.rtcAudioSession.description)
//        DLog.printLog("previousRoute:\n\(previousRoute.debugDescription)")
//        DLog.printLog("currentRoute:\n\(session.currentRoute.debugDescription)")
    }
    func printIfNotEqual(_ description:String, s1:String, s2:String) {
        if s1 != s2 {
            DLog.printLog("\(description) :\(s1) -> \(s2)")
        }
    }
    
    func getReasonString(reason: AVAudioSession.RouteChangeReason) -> String {
        switch reason {
        case .unknown:
            return "unknown"
        case .newDeviceAvailable:
            return "newDeviceAvailable"
        case .oldDeviceUnavailable:
            return "oldDeviceUnavailable"
        case .categoryChange:
            return "categoryChange"
        case .override:
            return "override"
        case .wakeFromSleep:
            return "wakeFromSleep"
        case .noSuitableRouteForCategory:
            return "noSuitableRouteForCategory"
        case .routeConfigurationChange:
            return "routeConfigurationChange"
        default:
            return "default"
        }
    }
    func audioSessionMediaServerTerminated(_ session: RTCAudioSession) {
        DLog.printLog("RTCAudioSessionDelegate-audioSessionMediaServerTerminated")
    }
    func audioSessionMediaServerReset(_ session: RTCAudioSession) {
        DLog.printLog("RTCAudioSessionDelegate-audioSessionMediaServerReset")
    }
    func audioSession(_ session: RTCAudioSession, didChangeCanPlayOrRecord canPlayOrRecord: Bool) {
        DLog.printLog("RTCAudioSessionDelegate-audioSession didChangeCanPlayOrRecord")
    }
    func audioSessionDidStartPlayOrRecord(_ session: RTCAudioSession) {
        DLog.printLog("RTCAudioSessionDelegate-audioSessionDidStartPlayOrRecord")
    }
    func audioSessionDidStartPlaudioSessionDidStopPlayOrRecordayOrRecord(_ session: RTCAudioSession) {
        DLog.printLog("RTCAudioSessionDelegate-audioSessionDidStartPlaudioSessionDidStopPlayOrRecordayOrRecord")
    }
    func audioSession(_ audioSession: RTCAudioSession, didChangeOutputVolume outputVolume: Float) {
        DLog.printLog("RTCAudioSessionDelegate-audioSession didChangeOutputVolume to \(audioSession.outputVolume)")
    }
    func audioSession(_ audioSession: RTCAudioSession, didDetectPlayoutGlitch totalNumberOfGlitches: Int64) {
        DLog.printLog("RTCAudioSessionDelegate-audioSession didDetectPlayoutGlitch totalNumberOfGlitches:\(totalNumberOfGlitches)")
    }
    func audioSession(_ audioSession: RTCAudioSession, willSetActive active: Bool) {
        DLog.printLog("RTCAudioSessionDelegate-audioSession willSetActive")
    }
    func audioSession(_ audioSession: RTCAudioSession, didSetActive active: Bool) {
        DLog.printLog("RTCAudioSessionDelegate-audioSession didSetActive")
    }
    func audioSession(_ audioSession: RTCAudioSession, failedToSetActive active: Bool, error: Error) {
        DLog.printLog("RTCAudioSessionDelegate-audioSession failedToSetActive")
    }
}

extension WebRTCClient: RTCAudioSessionActivationDelegate {
    
    func audioSessionDidActivate(_ session: AVAudioSession) {
        DLog.printLog("RTCAudioSessionActivationDelegate-audioSessionDidActivate")
    }
    
    func audioSessionDidDeactivate(_ session: AVAudioSession) {
        DLog.printLog("RTCAudioSessionActivationDelegate-audioSessionDidDeactivate")
    }
}

// MARK:- Audio control
extension WebRTCClient {
    func muteAudio() {
        DLog.printLog("[mini] WebRTCClient muteAudio")
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        DLog.printLog("[mini] WebRTCClient unmuteAudio")
        self.setAudioEnabled(true)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        DLog.printLog("[mini] speakerOff")
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                DLog.printLog("not initialized")
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
                try self.rtcAudioSession.setActive(false)
                DLog.printLog("speakerOff completed")
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
    public func speakerForceOn() {
        DLog.printLog("[mini] speakerForceOn")

        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            DLog.printLog("audioSession.outputVolume: \(audioSession.outputVolume)")
        } catch let error as NSError {
            DLog.printLog("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func speakerOn() {
        DLog.printLog("[mini] speakerOn")

        self.audioQueue.async { [weak self] in
            guard let self = self else {
                DLog.printLog("not initialized")
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: AVAudioSession.CategoryOptions.defaultToSpeaker)
//                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
            DLog.printLog("self.rtcAudioSession.outputVolume: \(self.rtcAudioSession.outputVolume)")
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        let inputTracks = self.peerConnection.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack }
        inputTracks.forEach { $0.isEnabled = isEnabled }

        let outputTracks = self.peerConnection.transceivers.compactMap { return $0.receiver.track as? RTCAudioTrack }
        outputTracks.forEach { $0.isEnabled = isEnabled }
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}

//MARK :- Orientation

extension WebRTCClient {
   
    func registerOrientationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(forceDeviceOrientationIfNeeded), name: NSNotification.Name(rawValue: "UIDeviceOrientationDidChangeNotification"), object: nil)
    }
    
    //Force device orientation is always landscape mode
    @objc func forceDeviceOrientationIfNeeded() {
        let orientation = UIDevice.current.orientation;
        
        switch orientation {
        case .portrait, .portraitUpsideDown:
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UIDeviceOrientationDidChangeNotification"), object: nil)
        default: break
        }
    }
}
