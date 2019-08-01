//
//  Bridge.m
//  msdemorn
//
//  Created by JONGYOUNG CHUNG on 31/07/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(MinischoolViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(onChangedStatus, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onErrorOccured, RCTDirectEventBlock)

@end
