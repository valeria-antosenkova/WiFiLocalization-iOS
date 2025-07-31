import SwiftUI
import UIKit


struct CardView<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content

    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }

            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 5)
        .preferredColorScheme(.light)
    }
}


struct WifiMapView: View {
    @StateObject var recorder = WifiStampsRecorder()
    @State private var newRoomName = ""
    @State private var roomList: [Room] = []
    @State private var selectedRoom: Room? = nil
    @State private var fileURL: URL? = nil
    
    // instruction card var
    @State private var isInstructionsExpanded = false
    
    // control of notifications
    @State private var showNotification = false
    @State private var notificationMessage = ""
    @State private var showToast = false
    @State private var toastTitle = ""
    @State private var toastMessage = ""
    
    // vars to track room data
    @State private var recordedRooms: [String: Int] = [:]
    @State private var sessionStartIndex = 0




    var body: some View {
        ZStack {
            // gradient background
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
                    
                    // App Title & Subtitle
                    HStack(alignment: .center, spacing: 12) {
                        VStack {
                            Image("TitleIcon")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .cornerRadius(12)
                            Spacer()
                                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("WiFi Navigation")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Indoor wayfinding system")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    
                    // Cards: Instructions, room management, ...
                    instructionsCard
                    roomManagementCard
                    recordingCard
                    roomDataOverviewCard
                    exportCard
                }
                .padding()
            }

            // Toast Notification Overlay
            .overlay(
                Group {
                    if showToast {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(toastTitle)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(toastMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding()
                        .transition(.opacity)
                    }
                }, alignment: .top
            )
        }
    }

    
   

    private var instructionsCard: some View {
        CardView(
            title: "How to Use",
            icon: "info.circle.fill",
            iconColor: Color(red: 0, green: 0.70, blue: 1)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    withAnimation {
                        isInstructionsExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(isInstructionsExpanded ? "Hide Instructions" : "Show Instructions")
                            
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: isInstructionsExpanded ? "chevron.up" : "chevron.down")
                    }
                }

                if isInstructionsExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Add a room to the list.")
                        Text("2. Select a room to record data.")
                        Text("3. Start recording WiFi data while moving around the room.")
                        Text("4. Stop recording when done.")
                        Text("5. Export your data when ready.")
                        Text("6. For navigation, import the data and press scan.")
                        Text("7. For navigation, import the data and press scan.")


                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .transition(.opacity.combined(with: .slide))
                }
            }
        }

    }

    private var roomManagementCard: some View {
        CardView(
            title: "Room Management",
            icon: "house.fill",
            iconColor: Color(red: 0, green: 0.70, blue: 1)
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Add rooms one by one")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                HStack {
                    TextField("Enter room name", text: $newRoomName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        guard !newRoomName.isEmpty else { return }
                        let room = Room(name: newRoomName)
                        if !roomList.contains(where: { $0.name == room.name }) {
                            roomList.append(room)
                            newRoomName = ""
                            showNotification(title: "Room added!", message: "Room has been added to the list.")
                        } else {
                            showNotification(title: "Room already exists", message: "A room with that name is already in the list.")
                        }
                        
                        
                        // if room added show notification
                        /*showNotification(title: "Room added!", message: "Room has been added to the list.")
                         */
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(red: 0, green: 0.70, blue: 1))
                            .cornerRadius(8)
                    }
                    .disabled(newRoomName.isEmpty)
                }
            }
        }
    }

    private var recordingCard: some View {
        
        CardView(
            title: "WiFi Recording",
            icon: "dot.radiowaves.left.and.right",
            iconColor: Color(red: 0, green: 0.70, blue: 1)
        ) {
            
            // selecting the room
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Room to start recording")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                Menu {
                    if roomList.isEmpty {
                            Text("No rooms available")
                        } else {
                            ForEach(roomList) { room in
                                Button(room.name) {
                                    selectedRoom = room
                                    print("Selected room: \(room.name)")
                                }
                            }
                        }
                } label: {
                    HStack {
                        Text(selectedRoom?.name ?? "Choose a room...")
                            .foregroundColor(selectedRoom != nil ? .primary : .gray)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                
            }

            // recording button
            VStack(spacing: 12) {
                Button(action: {
                    if recorder.isRecording {
                        recorder.stopRecording()

                        if let room = selectedRoom {
                            let newSamples = recorder.wifiStamps.count
                            let currentCount = recordedRooms[room.name] ?? 0
                            recordedRooms[room.name] = currentCount + newSamples
                        }

                        showNotification(title: "Recording stopped", message: "Data saved for \(selectedRoom?.name ?? "Unknown Room")")
                    } else if let room = selectedRoom {
                        
                        // start recording
                        recorder.startRecording(room: room.name)
                        sessionStartIndex = recorder.wifiStamps.count;              showNotification(title: "Recording started", message: "Recording data for \(room.name)")
                    }

                }) {
                    Text(recorder.isRecording ? "Stop Recording" : "Start Recording")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(recorder.isRecording ? Color.red : Color(red: 0, green: 0.75, blue: 1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedRoom == nil)

                if let selected = selectedRoom, recorder.isRecording {
                    Text("Recording for: \(selected.name)")
                        .foregroundColor(.gray)
                }

                Text("Samples Collected: \(recorder.isRecording ? currentSessionSampleCount : 0)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var roomDataOverviewCard: some View {
        CardView(
            title: "Room Data Overview",
            icon: "chart.bar.fill",
            iconColor: Color(red: 0, green: 0.70, blue: 1)) {
            if roomList.isEmpty {
                Text("No room data yet.")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                ForEach(roomList) { room in
                    let sampleCount = recorder.wifiStamps.filter { $0.roomName == room.name }.count
                    HStack {
                        Text(room.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.body)
                        Text("\(sampleCount) samples")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }


    private var exportCard: some View {
        CardView(
            title: "Export Data", 
            icon: "square.and.arrow.up.fill",
            iconColor: Color(red: 0, green: 0.70, blue: 1)
        ) {
            
            Button("Export All Data") {
                if let file = recorder.exportToFile() {
                    shareFile(file)
                }
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0, green: 0.75, blue: 0.50))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private func showNotification(title: String, message: String) {
        toastTitle = title
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
    
    private var currentSessionSampleCount: Int {
        max(0, recorder.wifiStamps.count - recorder.sessionStartIndex)
    }

}

private func shareFile(_ fileURL: URL) {
    let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        window.rootViewController?.present(activityVC, animated: true)
    }
}





#Preview {
    WifiMapView()
}
