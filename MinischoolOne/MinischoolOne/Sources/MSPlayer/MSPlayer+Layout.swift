//
//  MSPlayer+Layout.swift
//  MinischoolOne
//
//  Created by JONGYOUNG CHUNG on 05/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation

extension MSPlayer {
    
    public func bringLocalVideoToFront() {
        print("bringLocalVideoToFront")
        self.containerView.bringSubviewToFront(self.localVideoView)
    }
    
    public func bringRemoteVideoToFront() {
        print("bringRemoteVideoToFront")
        self.containerView.bringSubviewToFront(self.remoteVideoView)
    }
    
    public func bringWebViewToFront() {
        print("bringWebViewToFront")
        self.containerView.bringSubviewToFront(self.wkWebView)
    }
    
    public func sendLocalVideoToBack() {
        print("sendLocalVideoToBack")
        self.containerView.sendSubviewToBack(self.localVideoView)
    }
    
    public func sendRemoteVideoToBack() {
        print("sendRemoteVideoToBack")
        self.containerView.sendSubviewToBack(self.remoteVideoView)
    }
    
    public func sendWebViewToBack() {
        print("sendWebViewToBack")
        self.containerView.sendSubviewToBack(self.wkWebView)
    }
    
    public func relocateLocalVideoFrame() {
        if let frame = self.localVideoViewOriginalFrame {
            self.localVideoView.frame = self.getModifiedFrame(frame: frame)
        }
    }
    
    public func relocateRemoteVideoFrame() {
        if let frame = self.remoteVideoViewOriginalFrame {
            self.remoteVideoView.frame = self.getModifiedFrame(frame: frame)
        }
    }
    
    public func getModifiedFrame(frame: Frame) -> CGRect {
        let widthProportion : CGFloat = self.containerView.frame.width / 1920
        let heightProportion : CGFloat = self.containerView.frame.height / 1080
        
        return CGRect(x: frame.x * widthProportion, y: frame.y * heightProportion, width: frame.width * widthProportion, height: frame.height * heightProportion)
    }
}
