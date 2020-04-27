//
//  Utils.swift
//  MinischoolOne
//
//  Created by Michael Nguyen on 4/27/20.
//  Copyright © 2020 Minischool. All rights reserved.
//

import Foundation
import AVFoundation

struct Utils {
    
    static var deviceOS: String {
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        return "\(systemName) \(systemVersion)"
    }
    
    static var deviceName: String {
        return UIDevice.current.name
    }
    
    static var deviceModel: String {
        return UIDevice.current.type.rawValue
    }
    
    static var cameraStatus: String {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            return "Authorized"
            
        case .notDetermined: // The user has not yet been asked for camera access.
            return "Not Determined"
            
        case .denied: // The user has previously denied access to the camera.
            return "Denied"
            
        default:
            return "Unknown"
        }
    }
    
    static var microPhoneStatus: String {
        let persmission = AVAudioSession.sharedInstance().recordPermission
        
        switch persmission {
        case .granted: // The user has previously granted access to the microphone.
            return "Granted"
            
        case .denied: // The user has previously denied access to the microphone.
            return "Denied"
            
        case.undetermined: // The user has not yet been asked for microphone access.
            return "Not Determined"
            
        default:
            return "Unknown"
        }
    }
    
    static var speakerStatus: String {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        
        var status = false
        
        for output in currentRoute.outputs {

            switch output.portType {

            case .builtInSpeaker:
                status = true
                
            default:
                break
            }
        }
        return status ? "ON" : "OFF"
    }
    
    static var volumeOfSpeaker: Float {
        let currentVolume = AVAudioSession.sharedInstance().outputVolume
        return currentVolume
    }
}
