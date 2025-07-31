//
//  DataModel.swift
//  WiFiLocalization
//
//  Created by Valeria Antosenkova on 2025-05-19.
//

import Foundation



struct WifiStamp: Codable {
    let timestamp: String
    let roomName: String
    let rssi: String
    let bssid: String
    let latitude: Double
    let longitude: Double
    let networkName: String
}


