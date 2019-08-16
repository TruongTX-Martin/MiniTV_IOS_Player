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
        
        print("createVideo - modifiedFrame: \(modifiedFrame)")
        print("createVideo - self.baseView.frame: \(self.baseView.frame)")
        print("createVideo - self.wkWebView.frame: \(self.wkWebView.frame)")
        print("createVideo - self.backgroundImage?.frame: \(self.backgroundImage?.frame)")

        // video view 생성
        
        if isLocal {
            if self.localVideoView?.superview != nil {
                self.localVideoView.removeFromSuperview()
            }
        }else{
            if self.remoteVideoView?.superview != nil {
                self.remoteVideoView.removeFromSuperview()
            }
        }
        
        let videoView = UIView(frame: modifiedFrame)

        let z = frame.canvasOver ? frame.zIndex : frame.zIndex + ZINDEX.Canvas.rawValue + 1
        self.insertSubview(view: videoView, z: z)

        let renderer = RTCMTLVideoView(frame: videoView.frame)

        let scaleY = self.getCameraCaptureScaleY()
        print("scaleY = \(scaleY)")
        if isLocal {
            //좌우반전(거울처럼)
            renderer.transform = CGAffineTransform(scaleX: -1.0, y: scaleY)
            Client.shared.webRTCClient.startLocalVideo(renderer: renderer)
        }else{
            renderer.transform = CGAffineTransform(scaleX: 1, y: scaleY)
            Client.shared.webRTCClient.renderRemoteVideo(to: renderer)
        }
        self.embedView(renderer, into: videoView)

        if isLocal {
            self.localVideoView = videoView
        }else{
            self.remoteVideoView = videoView
        }
    }
    
    func getCameraCaptureScaleY() -> CGFloat{
        var scaleY = self.baseView.frame.height / self.containerView.frame.height

        guard let format = Client.shared.webRTCClient.videoCaptureFormat else { return scaleY }
        
        print(format.formatDescription)
        
        let camera:CMVideoDimensions = CMVideoFormatDescriptionGetDimensions( format.formatDescription )
        
        let H1 = self.baseView.frame.height
        let W1 = self.baseView.frame.width

        let H2 = CGFloat(camera.height)
        let W2 = CGFloat(camera.width)
        

        // W1 : H1 = W2 : H2 * x
        // H1*W2 = W1*H2*x
        // x = H1 * W2 / (W1 * H2)
        
        scaleY = H1 * W2 / (W1 * H2)

        print("\(W1) : \(H1) = \(W2) : \(H2) * \(scaleY)")

        return scaleY

    }
    
    func destroyVideo(isLocal: Bool) {
        
        var videoView: UIView?
        if isLocal {
            Client.shared.webRTCClient.stopCaptureLocalVideo()
            videoView = self.localVideoView
        }else{
            Client.shared.webRTCClient.stopRenderRemoteVideo()
            videoView = self.remoteVideoView
        }
        if videoView?.superview != nil {
            videoView?.removeFromSuperview()
        }
    }
    
    func hideVideo(isLocal: Bool) {
        if let videoView = isLocal ? self.localVideoView : self.remoteVideoView{
            videoView.isHidden = true
        }
    }
    
    private func reorderZIndex() {
        
    }
    
    private func embedView(_ view: UIView, into parentView: UIView) {
        print("embedView - view.frame: \(view.frame)")

        parentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))

        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        parentView.layoutIfNeeded()
    }
    
    @objc func timerCallback(){

        print("timerCallback movieClipLayers.count: \(self.movieClipLayers.count)")

        var countReadyToPlay = 0
        for item in self.movieClipLayers {
            let movieClipLayer = item.value
            guard let player = movieClipLayer.player else { continue }
            
            if player.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                countReadyToPlay += 1
            }
        }
        
        let stillLoadingImagesCount = self.backgroundImages.filter({$0.value == nil}).count
        print("countReadyToPlay: \(countReadyToPlay), stillLoadingImagesCount: \(stillLoadingImagesCount)")
        
        if countReadyToPlay >= self.movieClipLayers.count, stillLoadingImagesCount == 0
        {
            self.timer?.invalidate()
            self.loadResourceDone()
        }
    }
    
    func loadImage(_ resource: Resource) {
        
        print("loadImage: \(resource.src)")
        
        let url = URL(string:resource.src)
        
        let data = try? Data(contentsOf: url!)
        self.backgroundImages[resource.id] = UIImage(data: data!)
    }
    
    func loadMovieClip(_ resource: Resource) {
        
        print("loadMovieClip: \(resource.src)")
        
        let url = URL(string:resource.src)
        
        let player = AVPlayer(url: url!)
        let playerLayer = AVPlayerLayer(player: player)
        self.movieClipLayers[resource.id] = playerLayer
    }
    
    func loadResources(resources: [Resource]) {
        
        self.resourceList = resources
        
        for resource in resources.filter({$0.assetType == .image}) {
            self.backgroundImages[resource.id] = nil
        }
        
        DispatchQueue.global().async {

            for resource in resources {
                switch resource.assetType {
                case .image:
                    self.loadImage(resource)
                case .video:
                    self.loadMovieClip(resource)
                case .sound: break
                }
            }
        }
        
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }
    
    func createMovieClip(frame: MovieClipFrame) {
        print("createMovieClip: frame: \(frame)")
        for item in self.movieClipLayers {
            print("createMovieClip: item.key: \(item.key)")
        }
        guard let playerLayer = self.movieClipLayers[frame.id] else { return }
        let modifiedFrame = self.getModifiedFrame(frame: Frame(x: frame.x, y: frame.y, width: frame.width, height: frame.height, zIndex: frame.zIndex, canvasOver: frame.canvasOver))
        playerLayer.frame = modifiedFrame
        
        self.baseView.layer.addSublayer(playerLayer)
//        playerLayer.zPosition = frame.canvasOver ? frame.zIndex : frame.zIndex + ZINDEX.Canvas.rawValue
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
