import SwiftUI
import NetworkExtension

// MARK: - Custom Animation Components

struct ScanningWaveView: View {
    @State private var offset: CGFloat = -200

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.blue.opacity(0.3), Color.clear]),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .frame(height: 20)
            .offset(x: offset)
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    offset = 200
                }
            }
    }
}

struct AnimatedSignalBar: View {
    let delay: Double
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.blue)
            .frame(width: 3, height: isAnimating ? 16 : 8)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(delay), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct RoomDetectorView: View {
    @StateObject private var loader = JSONFileLoader()
    @State private var detectedBSSIDs: Set<String> = []
    @State private var roomConfidences: [(room: String, confidence: Double)] = []
    @State private var timer: Timer?
    @State private var isScanning: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.90, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 0.98)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    
                    // load the JSON file
                    CardView(
                        title: "Load JSON File",
                        icon: "tray.and.arrow.down.fill",
                        iconColor: Color(red: 0, green: 0.70, blue: 1)
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Import previously recorded WiFi data.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button(action: {
                                loader.loadJSONFile()
                            }) {
                                Text("Load JSON File")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0, green: 0.75, blue: 0.50))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }

                    // Room BSSID Overview
                    CardView(
                        title: "Room BSSID Overview",
                        icon: "wifi",
                        iconColor: Color(red: 0, green: 0.70, blue: 1)
                    ) {
                        if loader.isFileLoaded {
                            VStack(alignment: .leading, spacing: 8) {
                                // sort alphabetically by room name (key)
                                ForEach(loader.roomBSSIDMap.sorted(by: { $0.key < $1.key }), id: \ .key) { room, bssids in
                                    HStack {
                                        Text(room)
                                            .font(.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(bssids.count) BSSIDs")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Divider()
                                }
                            }
                        } else {
                            Text("No data loaded yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    CardView(
                        title: "Live Room Estimation",
                        icon: "location.viewfinder",
                        iconColor: .green
                    ) {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Scanning Status:")
                                    .font(.subheadline)
                                Circle()
                                    .fill(isScanning ? Color.green : Color.gray)
                                    .frame(width: 12, height: 12)
                                Text(isScanning ? "Active" : "Stopped")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Button(action: {
                                isScanning ? stopScanning() : startScanning()
                            }) {
                                Text(isScanning ? "Stop Scanning" : "Start Scanning")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isScanning ? Color.red : Color(red: 0, green: 0.70, blue: 1))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            if isScanning {
                                VStack(spacing: 10) {
                                    HStack(spacing: 6) {
                                        ForEach(0..<5) { i in
                                            AnimatedSignalBar(delay: Double(i) * 0.2)
                                        }
                                    }
                                }
                            }

                            if roomConfidences.isEmpty {
                                Text("Waiting for scan...")
                                    .foregroundColor(.secondary)
                            } else {
                                
                                // display room confidences
                                VStack(alignment: .leading, spacing: 12) {
                                    Text ("You are most likely in...")
                                    ForEach(roomConfidences, id: \.room) { entry in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(entry.room)
                                                .fontWeight(.medium)

                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(.systemGray5))
                                                    .frame(height: 18)

                                                // render a progress bar for room confidence
                                                GeometryReader { geometry in
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color(red: 0, green: 0.70, blue: 1))
                                                        .frame(width: geometry.size.width * CGFloat(entry.confidence), height: 18)

                                                    Text(String(format: "%.0f%%", entry.confidence * 100))
                                                        .font(.caption2)
                                                        .foregroundColor(.white)
                                                        .padding(.leading, 8)
                                                        .frame(height: 18, alignment: .center)
                                                }
                                                .frame(height: 18)
                                            }

                                        }
                                    }
                                }

                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onDisappear {
            stopScanning()
        }
    }
    
    // MARK: - Scanning

    // fetching network data here again
    func startScanning() {
        stopScanning() // ensure no duplicates
        isScanning = true
        
        // fetch data every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            NEHotspotNetwork.fetchCurrent { network in
                guard let net = network else {
                    print("No current network")
                    return
                }

                let currentBSSID = net.bssid
                DispatchQueue.main.async {
                    self.detectedBSSIDs = [currentBSSID]
                    self.computeRoomMatch()
                }
            }
        }
    }

    func stopScanning() {
        timer?.invalidate()
        timer = nil
        isScanning = false
    }

    // MARK: - Room Match Computation

    func computeRoomMatch() {
        // 1. for each bssid count how many rooms it appears in
        var bssidRoomCount: [String: Int] = [:]
        // iterate over the dictionary roomBSSIDMap (JSONFileLoader) "Kitchen": Set("BSSID_1", "BSSID_2")
        for (_, bssids) in loader.roomBSSIDMap {
            for bssid in bssids {
                // if bssid is already in the dictionary, get its count, otherwise count is 0 for missing key, update count +1
                bssidRoomCount[bssid, default: 0] += 1
            }
        }
        
        var results: [(String, Double)] = []

        // 2. for each room calculate confidence score
        for (room, bssids) in loader.roomBSSIDMap {
            var score: Double = 0.0
            for bssid in detectedBSSIDs {
                
                //if this BSSID has a count in the dictionary, use it
                // otherwise count that it appears in one room
                if bssids.contains(bssid) {
                    let count = bssidRoomCount[bssid] ?? 1 // if its nil, we detected a bssid that's not mapped in the json but still want to  give it weight
                    score += 1.0 / Double(count) // more unique overlap, higher score
                }
            }
            results.append((room, score))
        }
        
        let total = results.map { $0.1 }.reduce(0, +)
        
        // 3. turn the scores into percentages
        if total > 0 {
            self.roomConfidences = results.map { ($0.0, $0.1 / total) }.sorted { $0.1 > $1.1 } // each value is now between 0.0 and 1.0
            // and sort by descending order to show the room with highest likelihood first
        } else {
            self.roomConfidences = [] // if no detected bssids matched anything, clear the list - the ui shows 'waiting for scan'
        }
    }
}

#Preview {
    RoomDetectorView()
}
