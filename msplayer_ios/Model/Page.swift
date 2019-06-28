//
//  Page.swift
//  msplayer_ios
//
//  Created by neo on 14/06/2019.
//  Copyright © 2019 neo. All rights reserved.
//

import Foundation

struct Page: Codable {
    let id: Int
    let title: String
    let bgImage: Asset?
    let bgSound: Asset?
    let bgSoundProperty: BgSoundProperty?
    let onLoadStart: Int?
    let zIndex: Int
    let drawingSize: Int
    let drawingInit: Int
    let components: [Component]
}
struct ImageSize: Codable {
    let width: Int
    let height: Int
}

struct BgSoundProperty: Codable {
    let stopNextScene: Bool
    let allowMixed: Bool
    let isMusic: Bool
    let loop: Bool
}

struct Asset: Codable {
    let id: Int
    let createdDate: String
    let assetId: Int
    let src: String
    let sourceType: String
    let assetType: String
    let title: String
    let fileSize: Int
    let imageSize: ImageSize
}

struct Component: Codable {
    let id: Int
}
