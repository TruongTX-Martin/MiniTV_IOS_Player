//
//  MinischoolView.swift
//  msdemorn
//
//  Created by JONGYOUNG CHUNG on 31/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import MinischoolOne

class MinischoolView: UIView, MSPlayerDelegate {
  
  func MSPlayer(_ player: MSPlayer, didChangedStatus newStatus: MSPlayerStatus) {
    if onChangedStatus != nil {
      print("newStatus.rawValue: \(newStatus.rawValue)")
      onChangedStatus!(["status": newStatus.rawValue])
    }
  }
  
  func MSPlayer(_ player: MSPlayer, errorOccured error: Error) {
    if onErrorOccured != nil {
      print("error.localizedDescription: \(error.localizedDescription)")
      onErrorOccured!(["error": error.localizedDescription])
    }
  }
  
  @objc var url: NSString = "" {
    didSet {
      print("url: \(url)")
    }
  }

  var containerView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)

    containerView = UIView.init(frame: frame)
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(containerView)

  }

  override func didMoveToSuperview() {
    print("didMoveToSuperview")
    let player = MinischoolOne.MSPlayer(self.containerView, viewController: nil, serviceAppVersion: "1.0", url: self.url as String)
    player!.delegate = self
    player!.run()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc var onChangedStatus: RCTDirectEventBlock?
  @objc var onErrorOccured: RCTDirectEventBlock?
  
}


