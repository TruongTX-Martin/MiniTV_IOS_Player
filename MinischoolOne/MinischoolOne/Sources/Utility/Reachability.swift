//
//  Reachability.swift
//  MinischoolOne
//
//  Created by Michael Nguyen on 4/27/20.
//  Copyright © 2020 Minischool. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreTelephony

enum ReachabilityStatus {
    case notReachable
    case reachableViaWWAN
    case reachableViaWiFi
}

enum RadioAccessTechnology: String {
    case cdma = "CTRadioAccessTechnologyCDMA1x"
    case edge = "CTRadioAccessTechnologyEdge"
    case gprs = "CTRadioAccessTechnologyGPRS"
    case hrpd = "CTRadioAccessTechnologyeHRPD"
    case hsdpa = "CTRadioAccessTechnologyHSDPA"
    case hsupa = "CTRadioAccessTechnologyHSUPA"
    case lte = "CTRadioAccessTechnologyLTE"
    case rev0 = "CTRadioAccessTechnologyCDMAEVDORev0"
    case revA = "CTRadioAccessTechnologyCDMAEVDORevA"
    case revB = "CTRadioAccessTechnologyCDMAEVDORevB"
    case wcdma = "CTRadioAccessTechnologyWCDMA"

    var description: String {
        switch self {
        case .gprs, .edge, .cdma:
            return "2G"
        case .lte:
            return "4G"
        default:
            return "3G"
        }
    }
}

public class Reachability {
    static let shared = Reachability()
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
    private init() {
        
    }
    
    public func isConnectedToNetwork() -> Bool {
        return currentReachabilityStatus != .notReachable
    }
    
    func getConnectionType() -> String {
        if currentReachabilityStatus != .notReachable {
            if currentReachabilityStatus == .reachableViaWWAN {
                let networkInfo = CTTelephonyNetworkInfo()
                var carrierTypeName = ""
                if #available(iOS 12.0, *) {
                    let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
                    if let value = carrierType?.first?.value {
                        carrierTypeName = value
                    }
                } else {
                    carrierTypeName = networkInfo.currentRadioAccessTechnology ?? ""
                }
                
                let tecnology = RadioAccessTechnology(rawValue: carrierTypeName)
                return tecnology?.description ?? "UNKNOWN"
            } else {
                return "WIFI"
            }
        } else {
            return "NO INTERNET"
        }
    }
}


