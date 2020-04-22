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

    func prepareSound(url : URL) {
        urlIem = url
        let playerItem = AVPlayerItem(url: urlIem!)
        player = AVPlayer(playerItem: playerItem)
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

    func stop(){
        player.pause()
    }

    func play() {
        player.seek(to: .zero)
        player.play()
    }
    
    func status() -> AVPlayerItem.Status? {
        return player.currentItem?.status
    }
}
