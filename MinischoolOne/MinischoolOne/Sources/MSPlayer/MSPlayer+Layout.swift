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
        self.containerView.bringSubviewToFront(self.localVideoView)
    }
    
    public func bringRemoteVideoToFront() {
        self.containerView.bringSubviewToFront(self.remoteVideoView)
    }
    
    public func bringWebViewToFront() {
        self.containerView.bringSubviewToFront(self.webView)
    }
    
    public func sendLocalVideoToBack() {
        self.containerView.sendSubviewToBack(self.localVideoView)
    }
    
    public func sendRemoteVideoToBack() {
        self.containerView.sendSubviewToBack(self.remoteVideoView)
    }
    
    public func sendWebViewToBack() {
        self.containerView.sendSubviewToBack(self.webView)
    }
    
    public func setLocalVideoFrame(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.localVideoView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    public func setRemoteVideoFrame(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.remoteVideoView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
}
