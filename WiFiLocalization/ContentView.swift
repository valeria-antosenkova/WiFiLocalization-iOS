//
//  ContentView.swift
//  WiFiLocalization
//
//  Created by Valeria Antosenkova on 2025-07-22.
//

import Foundation
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WifiMapView()
                .tabItem {
                    Label("Mapper", systemImage: "square.and.pencil")
                }
            RoomDetectorView()
                .tabItem { Label("Localization", systemImage: "location.viewfinder")  }
            
        }
    }
}
#Preview {
    ContentView()
}
 
