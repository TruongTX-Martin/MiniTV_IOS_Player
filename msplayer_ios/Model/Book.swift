//
//  Book.swift
//  msplayer_ios
//
//  Created by neo on 14/06/2019.
//  Copyright © 2019 neo. All rights reserved.
//

import Foundation

struct Book: Codable {
    let id: Int
    let pageCount: Int
    let componentCount: Int
    let assetCount: Int
    let pageGroups: [PageGroup]

}


struct PageGroup: Codable {
    let id: Int
    let title: String
    let zIndex: Int
    let pages: [Page]
}

// https://jiseobkim.github.io/swift/2018/07/21/swift-Alamofire%EC%99%80-Codable.html


