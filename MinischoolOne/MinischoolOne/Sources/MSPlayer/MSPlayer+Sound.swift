//
//  MSPlayer+Sound.swift
//  MinischoolOne
//
//  Created by Michael Nguyen on 4/16/20.
//  Copyright © 2020 Minischool. All rights reserved.
//

import Foundation
import AVFoundation

extension MSPlayer {
    
    func loadSoundEffect(_ resource: Resource) {
        
        if let url = URL(string:resource.src) {
            let soundPlayer = MNMusicPlayer()
            soundPlayer.prepareSound(url: url)
            soundEffectLayers[resource.id] = soundPlayer
            DLog.printLog("Load sound effect id = \(resource.id), url = \(resource.src)")
        }
    }
    
    func playSoundEffect(_ soundId : Int, options: SoundOptions?) {
        guard let audioPlayer = soundEffectLayers[soundId] else {
            DLog.printLog("Sound ID \(soundId) does not exists")
            return
        }
        DLog.printLog("Play sound effect id \(soundId) url = \(String(describing: audioPlayer.urlIem?.absoluteString))")
        audioPlayer.play(options)
    }
    
    func stopSoundEffect(_ soundId : Int) {
        guard let audioPlayer = soundEffectLayers[soundId] else {
            DLog.printLog("Sound ID \(soundId) does not exists")
            return
        }
        DLog.printLog("Stop sound effect: \(audioPlayer.urlIem?.absoluteString ?? "")")
        audioPlayer.stop()
    }
    
    func stopAllSoundEffect() {
        DLog.printLog("Stop all sound effects")
        for item in soundEffectLayers {
            let audioPlayer = item.value
            audioPlayer.stop()
        }
    }
    
    func preloadCameraEffectSound() {
        let bundle = Bundle(for: Self.self)
        
        if let filePath = bundle.path(forResource: "camera_effect", ofType: "mp3") {
            let url = URL(fileURLWithPath: filePath, relativeTo: nil)
            
            let soundPlayer = MNMusicPlayer()
            soundPlayer.prepareSound(url: url)
            
            soundEffectLayers[cameraEffectId] = soundPlayer
            
            DLog.printLog("Load camera effect sound")
        }
    }
    
    func playCameraEffectSound() {
        playSoundEffect(cameraEffectId, options: nil)
    }
    
    func stopCameraEffectSound() {
        stopSoundEffect(cameraEffectId)
    }
}
