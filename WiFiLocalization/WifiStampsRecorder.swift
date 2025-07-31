//
//  WifiStampsRecorder.swift
//  WiFiLocalization
//
//  Starts and stops recording of wifi stamps, location information, fetches network information, and exports this data.
//
//  Created by Valeria Antosenkova on 2025-05-19.
//

import Foundation
import CoreLocation
import NetworkExtension



class WifiStampsRecorder: NSObject, CLLocationManagerDelegate, ObservableObject {

    private var locationManager = CLLocationManager()
    private var currentRoomName: String = ""
    private var lastSampleTime: Date = .distantPast

    @Published var wifiStamps: [WifiStamp] = []
    @Published var isRecording = false
    @Published var sessionStartIndex: Int = 0

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func startRecording(room: String) 
    {
        
        currentRoomName = room
        sessionStartIndex = wifiStamps.count
        isRecording = true
        
        locationManager.requestWhenInUseAuthorization() // access user location only while the app is in use
        locationManager.startUpdatingLocation() // starts gps tracking; ios polls GPS updates in the background
    }

    func stopRecording() {
        isRecording = false
        locationManager.stopUpdatingLocation()
    }

    // method for continuos gps tracking
    // when new location is available, iOS calls this method automatically
    // we receive an array of CLLocation objects and handle its data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRecording, let location = locations.last else { return }

        // whenever location updates, also fetch network data
        NEHotspotNetwork.fetchCurrent { network in
            guard let net = network else {
                print("Couldn't get network - network is nil")
                return
            }

            let currentBSSID = net.bssid
            let ssid = net.ssid

            let stamp = WifiStamp(
                timestamp: Self.formatDate(Date()),
                roomName: self.currentRoomName,
                rssi: String(format: "%.3f", net.signalStrength),
                bssid: currentBSSID,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                networkName: ssid
            )

            DispatchQueue.main.async {
                self.wifiStamps.append(stamp)
                
            }
        }
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }

    func exportToFile() -> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())
        let filename = "WiFiMap_\(timestamp).json"

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        let jsonObjects = wifiStamps.map { stamp in
            return [
                "timestamp": stamp.timestamp,
                "roomName": stamp.roomName,
                "networkName": stamp.networkName,
                "rssi": stamp.rssi,
                "bssid": stamp.bssid,
                "latitude": stamp.latitude,
                "longitude": stamp.longitude
            ] as [String: Any]
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObjects, options: [.prettyPrinted])
            try data.write(to: url)
            return url
        } catch {
            print("Error saving JSON: \(error)")
            return nil
        }
    }
}
