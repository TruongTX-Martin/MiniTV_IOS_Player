//
//  MSPlayer+Video.swift
//  WebRTC-Demo
//
//  Created by JONGYOUNG CHUNG on 04/07/2019.
//  Copyright © 2019 Stas Seldin. All rights reserved.
//

import Foundation
import WebRTC

extension MSPlayer{
    
    func createVideo(isLocal: Bool, frame: Frame) {

        if isLocal {
            self.localVideoViewOriginalFrame = frame
        }else{
            self.remoteVideoViewOriginalFrame = frame
        }
        
        let modifiedFrame = self.getModifiedFrame(frame: frame)
        
        // video view 생성
        
        if isLocal {
            if self.localVideoView != nil, self.localVideoView.isHidden {
                self.localVideoView.isHidden = false
                return
            }
            
            if self.localVideoView?.superview != nil {
                self.localVideoView.removeFromSuperview()
            }
            self.localVideoView = UIView(frame: modifiedFrame)

            if frame.zIndex <= 2 {
                self.bringLocalVideoToFront()
            }else{
                self.sendLocalVideoToBack()
            }
            
        }else{
            if self.remoteVideoView != nil, self.remoteVideoView.isHidden {
                self.remoteVideoView.isHidden = false
                return
            }

            if self.remoteVideoView?.superview != nil {
                self.remoteVideoView.removeFromSuperview()
            }
            self.remoteVideoView = UIView(frame: modifiedFrame)

            if frame.zIndex <= 2 {
                self.bringRemoteVideoToFront()
            }else{
                self.sendRemoteVideoToBack()
            }
        }
        
        let videoView = isLocal ? self.localVideoView! : self.remoteVideoView!
        self.containerView.addSubview(videoView)

        #if arch(arm64)
        // Using metal (arm64 only)
        print("arch(arm64)")
        let renderer = RTCMTLVideoView(frame: videoView.frame)
        renderer.videoContentMode = .scaleAspectFill
        
//        renderer.rotationOverride = NSValue(nonretainedObject: RTCVideoRotation._0)
        #else
        // Using OpenGLES for the rest
        let renderer = RTCEAGLVideoView(frame: videoView.frame)
        #endif
        
        if isLocal {
            //좌우반전(거울처럼)
//            if UIDevice.current.orientation.isLandscape {
                renderer.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//            } else {
//                renderer.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
//            }
            
//            Client.shared.webRTCClient.startCaptureLocalVideo(renderer: renderer)
            Client.shared.webRTCClient.startLocalVideo(renderer: renderer)
        }else{
            Client.shared.webRTCClient.renderRemoteVideo(to: renderer)
        }
        self.embedView(renderer, into: videoView)
    }
    
    func destroyVideo(isLocal: Bool) {
        if isLocal {
            
            Client.shared.webRTCClient.stopCaptureLocalVideo()
            if self.localVideoView?.superview != nil {
                self.localVideoView.removeFromSuperview()
            }
        }else{
            Client.shared.webRTCClient.stopRenderRemoteVideo()
            if self.remoteVideoView?.superview != nil {
                self.remoteVideoView.removeFromSuperview()
            }
        }
    }
    
    func hideVideo(isLocal: Bool) {
        if let videoView = isLocal ? self.localVideoView : self.remoteVideoView{
            videoView.isHidden = true
        }
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }
    
    @objc func timerCallback(){

        print("timerCallback movieClipLayers.count: \(self.movieClipLayers.count)")

        var countReadyToPlay = 0
        for item in self.movieClipLayers {
            let movieClipLayer = item.value
            guard let player = movieClipLayer.player else { continue }
            
            print("player.currentItem: \(player.currentItem?.debugDescription)")
            
            if player.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                countReadyToPlay += 1
            }
        }
        
        print("countReadyToPlay: \(countReadyToPlay)")
        
        if countReadyToPlay >= self.movieClipLayers.count {
            self.timer?.invalidate()
            self.loadVideoDone()
        }

    }
    
    func loadMovieClip(movieClip: MovieClip) {
        
        print("loadMovieClip: \(movieClip.src)")
        
        let url = URL(string:movieClip.src)
        
        let player = AVPlayer(url: url!)
        let playerLayer = AVPlayerLayer(player: player)
        self.movieClipLayers[movieClip.id] = playerLayer
        
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }
    
    func loadMovieClips(movieClips: [MovieClip]) {

        for movieClip in movieClips {
            self.loadMovieClip(movieClip: movieClip)
        }
    }
    
    func createMovieClip(frame: MovieClipFrame) {
        print("createMovieClip: frame: \(frame)")
        for item in self.movieClipLayers {
            print("createMovieClip: item.key: \(item.key)")
        }
        guard let playerLayer = self.movieClipLayers[frame.id] else { return }
        let modifiedFrame = self.getModifiedFrame(frame: Frame(x: frame.x, y: frame.y, zIndex: frame.zIndex, width: frame.width, height: frame.height))
        playerLayer.frame = modifiedFrame
        
        self.containerView.layer.addSublayer(playerLayer)
        if let player = playerLayer.player {
            print("player.play()")
            player.play()
        }
    }
    
    func destoryMovieClip(id: Int) {
        print("destoryMovieClip movieClipLayers.count: \(self.movieClipLayers.count)")

        guard let playerLayer = self.movieClipLayers[id] else { return }
        playerLayer.player?.pause()
        playerLayer.player?.seek(to: .zero)
        playerLayer.removeFromSuperlayer()
    }
    
}
