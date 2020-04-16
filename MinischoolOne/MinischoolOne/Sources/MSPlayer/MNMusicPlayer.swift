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
        let playerItem = AVPlayerItem.init(url: urlIem!)
        player = AVPlayer.init(playerItem: playerItem)
        playAudioBackground()
    }

    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
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
