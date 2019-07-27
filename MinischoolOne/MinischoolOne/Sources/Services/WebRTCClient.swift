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
//        print("set remoteSdp: \(remoteSdp)")
        self.peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate) {
        self.peerConnection.add(remoteCandidate)
    }
    
    // MARK: Media
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }

        guard
            let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }),
        
            // choose highest res
            let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
        
            // choose highest fps
//            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last),
            
            let maxFrameRate = self.localVideoMandatory?["maxFrameRate"] else {
            return
        }

        capturer.startCapture(with: frontCamera,
                              format: format,
                              fps: maxFrameRate)
        
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
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Video
        let videoTrack = self.createVideoTrack()
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        // Data
//        if let dataChannel = createDataChannel() {
//            dataChannel.delegate = self
//            self.localDataChannel = dataChannel
//        }
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
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
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
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
        debugPrint("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remote stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
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
        print("RTCAudioSessionDelegate-audioSessionDidBeginInterruption")
    }
    func audioSessionDidEndInterruption(_ session: RTCAudioSession, shouldResumeSession: Bool) {
        print("RTCAudioSessionDelegate-audioSessionDidEndInterruption")
    }
    func audioSessionDidChangeRoute(_ session: RTCAudioSession, reason: AVAudioSession.RouteChangeReason, previousRoute: AVAudioSessionRouteDescription) {
        print("RTCAudioSessionDelegate-audioSessionDidChangeRoute reason:\(reason) previousRoute:\(previousRoute)")
    }
    func audioSessionMediaServerTerminated(_ session: RTCAudioSession) {
        print("RTCAudioSessionDelegate-audioSessionMediaServerTerminated")
    }
    func audioSessionMediaServerReset(_ session: RTCAudioSession) {
        print("RTCAudioSessionDelegate-audioSessionMediaServerReset")
    }
    func audioSession(_ session: RTCAudioSession, didChangeCanPlayOrRecord canPlayOrRecord: Bool) {
        print("RTCAudioSessionDelegate-audioSession didChangeCanPlayOrRecord")
    }
    func audioSessionDidStartPlayOrRecord(_ session: RTCAudioSession) {
        print("RTCAudioSessionDelegate-audioSessionDidStartPlayOrRecord")
    }
    func audioSessionDidStartPlaudioSessionDidStopPlayOrRecordayOrRecord(_ session: RTCAudioSession) {
        print("RTCAudioSessionDelegate-audioSessionDidStartPlaudioSessionDidStopPlayOrRecordayOrRecord")
    }
    func audioSession(_ audioSession: RTCAudioSession, didChangeOutputVolume outputVolume: Float) {
        print("RTCAudioSessionDelegate-audioSession didChangeOutputVolume")
    }
    func audioSession(_ audioSession: RTCAudioSession, didDetectPlayoutGlitch totalNumberOfGlitches: Int64) {
        print("RTCAudioSessionDelegate-audioSession didDetectPlayoutGlitch totalNumberOfGlitches:\(totalNumberOfGlitches)")
    }
    func audioSession(_ audioSession: RTCAudioSession, willSetActive active: Bool) {
        print("RTCAudioSessionDelegate-audioSession willSetActive")
    }
    func audioSession(_ audioSession: RTCAudioSession, didSetActive active: Bool) {
        print("RTCAudioSessionDelegate-audioSession didSetActive")
    }
    func audioSession(_ audioSession: RTCAudioSession, failedToSetActive active: Bool, error: Error) {
        print("RTCAudioSessionDelegate-audioSession failedToSetActive")
    }
}

extension WebRTCClient: RTCAudioSessionActivationDelegate {
    
    func audioSessionDidActivate(_ session: AVAudioSession) {
        print("RTCAudioSessionActivationDelegate-audioSessionDidActivate")
    }
    
    func audioSessionDidDeactivate(_ session: AVAudioSession) {
        print("RTCAudioSessionActivationDelegate-audioSessionDidDeactivate")
    }
}

// MARK:- Audio control
extension WebRTCClient {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        print("speakerOff")
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                print("not initialized")
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
//                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
//                try self.rtcAudioSession.overrideOutputAudioPort(.none)
                try self.rtcAudioSession.setActive(false)
                print("speakerOff completed")
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    func speakerOn() {
        print("speakerOn")
        
        /*
         RTCAudioSessionDelegate-audioSessionDidChangeRoute reason:AVAudioSessionRouteChangeReason previousRoute:<AVAudioSessionRouteDescription: 0x2809b1520,
         inputs = (
         "<AVAudioSessionPortDescription: 0x2809b0830, type = MicrophoneBuiltIn; name = iPhone \Ub9c8\Uc774\Ud06c; UID = Built-In Microphone; selectedDataSource = \Uc55e\Uba74>"
         );
         outputs = (
         "<AVAudioSessionPortDescription: 0x2809b0e20, type = Speaker; name = \Uc2a4\Ud53c\Ucee4; UID = Speaker; selectedDataSource = (null)>"
         )>
         */
        
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                print("not initialized")
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setActive(true)
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                print("speakerOn completed")
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
            print("self.rtcAudioSession.outputDataSource \(self.rtcAudioSession.outputDataSource)")
        }
//        speakerOn1()
    }

    private func setAudioEnabled(_ isEnabled: Bool) {
        let audioTracks = self.peerConnection.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack }
        audioTracks.forEach { $0.isEnabled = isEnabled }
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
