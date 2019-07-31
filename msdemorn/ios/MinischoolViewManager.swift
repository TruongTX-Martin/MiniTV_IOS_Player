//
//  MinischoolViewManager.swift
//  msdemorn
//
//  Created by JONGYOUNG CHUNG on 31/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation

@objc(MinischoolViewManager)
class MinischoolViewManager: RCTViewManager {
  override func view() -> UIView! {
    return MinischoolView()
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
