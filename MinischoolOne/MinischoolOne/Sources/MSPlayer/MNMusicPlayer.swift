//
//  MNMusicPlayer.swift
//  MinischoolOne
//
//  Created by Michael Nguyen on 4/16/20.
//  Copyright © 2020 Minischool. All rights reserved.
//

import Foundation
import AVFoundation

class MNMusicPlayer : NSObject {
    var player = AVPlayer()
    var urlIem: URL?
    
    private var options: SoundOptions? {
        didSet {
            if options != nil {
                isLoop = options!.loop
                volumeLevel = options!.volume
            } else {
                isLoop = false
                volumeLevel = 1.0
            }
        }
    }
    
    //volume level: 0.05~1.0
    var volumeLevel: Float = 1.0 {
        didSet {
            player.volume = volumeLevel
        }
    }
    
    //playback audio or not
    var isLoop: Bool = false {
        didSet {
            if isLoop {
                player.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    

    func prepareSound(url : URL) {
        urlIem = url
        let playerItem = AVPlayerItem(url: urlIem!)
        player = AVPlayer(playerItem: playerItem)
        isLoop = false
        volumeLevel = 1.0
        playAudioBackground()
    }

    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            DLog.printLog("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            DLog.printLog("Session is Active")
        } catch {
            DLog.printLog(error)
        }
    }

    func stop() {
        isLoop = false
        player.pause()
    }

    func play(_ options: SoundOptions?) {
        self.options = options
        player.seek(to: .zero)
        player.play()
    }
    
    func status() -> AVPlayerItem.Status? {
        return player.currentItem?.status
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        player.currentItem?.seek(to: .zero)
    }
}
