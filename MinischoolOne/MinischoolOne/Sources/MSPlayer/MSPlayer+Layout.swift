//
//  MSPlayer+Layout.swift
//  MinischoolOne
//
//  Created by JONGYOUNG CHUNG on 05/07/2019.
//  Copyright © 2019 Minischool. All rights reserved.
//

import Foundation

extension MSPlayer {
    /*
    public func bringLocalVideoToFront() {
        DLog.printLog("bringLocalVideoToFront")
        self.baseView.bringSubviewToFront(self.localVideoView)
    }
    
    public func bringRemoteVideoToFront() {
        DLog.printLog("bringRemoteVideoToFront")
        self.baseView.bringSubviewToFront(self.remoteVideoView)
    }
    
    public func bringWebViewToFront() {
        DLog.printLog("bringWebViewToFront")
        self.baseView.bringSubviewToFront(self.wkWebView)
    }
    
    public func sendLocalVideoToBack() {
        DLog.printLog("sendLocalVideoToBack")
        self.baseView.sendSubviewToBack(self.localVideoView)
    }
    
    public func sendRemoteVideoToBack() {
        DLog.printLog("sendRemoteVideoToBack")
        self.baseView.sendSubviewToBack(self.remoteVideoView)
    }
    
    public func sendWebViewToBack() {
        DLog.printLog("sendWebViewToBack")
        self.baseView.sendSubviewToBack(self.wkWebView)
    }
    */
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
        
        let fullSizeFrame = CGRect(x: 0, y: 0, width: self.baseView.frame.width, height: self.baseView.frame.height)
        if frame.width == maxWidth, frame.height == maxHeight {
            return fullSizeFrame
        }
        
        let widthProportion : CGFloat = self.baseView.frame.width / maxWidth
        let heightProportion : CGFloat = self.baseView.frame.height / maxHeight
        
        return CGRect(x: frame.x * widthProportion, y: frame.y * heightProportion, width: frame.width * widthProportion, height: frame.height * heightProportion)
    }
    
    public func setBackground(_ id: Int) {
        self.removeBackground()
        DLog.printLog("setBackground: \(id)")
        if let image =  self.backgroundImages[id] {
            self.backgroundImage = UIImageView(frame: self.baseView.bounds)
//            self.backgroundImage = UIImageView(frame: CGRect(x:0, y:100, width: 800, height: 500))
            self.backgroundImage.image = image
            self.backgroundImage.contentMode =  UIView.ContentMode.scaleAspectFit
            
            self.insertSubview(view: self.backgroundImage, z: ZINDEX.Background.rawValue)

//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//            backgroundImage.addGestureRecognizer(tap)
//            backgroundImage.isUserInteractionEnabled = true
            
        }else{
            DLog.printLog("setBackground: no image - \(id)")
        }
    }
    
    public func removeBackground() {
        guard self.backgroundImage?.superview != nil else {
            return
        }
        DLog.printLog("removeBackground")
        self.backgroundImage.removeFromSuperview()
        self.backgroundImage = nil
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        DLog.printLog("handleTap")

        self.wkWebView.superview?.bringSubviewToFront(self.wkWebView)

        for v in self.baseView.subviews {
            DLog.printLog("\(v.tag): \(v.debugDescription)")
        }
    }

    public func insertSubview(view: UIView, z: CGFloat) {
        //z index와 subview의 index는 반대임. subview목록에서 0번째 뷰가 맨 뒤에 위치하게 됨
        let parent = self.baseView!
        let oldCount = parent.subviews.count
        DLog.printLog("insertSubview: oldCount - \(oldCount)")

        view.tag = Int(z)
        if oldCount == 0 {
            parent.addSubview(view)
        }else {
            for v in parent.subviews.sorted(by: { $0.tag < $1.tag}) {
                //자신보다 z index 큰 뷰를 발견하면 그 뷰 아래 놓는다(그 뷰 보다 앞)
                if v.tag > Int(z) {
                    DLog.printLog("\(z) is aboveSubview \(v.tag)")
                    parent.insertSubview(view, aboveSubview: v)
                    break
                }
            }
            if parent.subviews.count == oldCount {
                DLog.printLog("insertSubview: sendSubviewToBack")
                parent.insertSubview(view, at: 0)
            }
        }

        self.baseView.setNeedsDisplay()

        for v in parent.subviews {
            DLog.printLog("\(v.tag): \(v.debugDescription)")
        }
    }
}
