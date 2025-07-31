

import Foundation

import SwiftUI
import UniformTypeIdentifiers

class JSONFileLoader: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var roomBSSIDMap: [String: Set<String>] = [:] // roomName -> BSSIDs; "Kitchen": Set("BSSID_1", "BSSID_2")
    @Published var isFileLoaded = false

    func loadJSONFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(documentPicker, animated: true)
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        parseJSONFile(from: url)
    }

    private func parseJSONFile(from url: URL) {
        // Request access to the file in sandbox
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to access due to security scoped resource")
            return
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let stamps = try decoder.decode([WifiStamp].self, from: data)

            var mapping: [String: Set<String>] = [:]

            for stamp in stamps {
                mapping[stamp.roomName, default: Set()].insert(stamp.bssid)
            }

            DispatchQueue.main.async {
                self.roomBSSIDMap = mapping
                self.isFileLoaded = true
            }

        } catch {
            print("Failed to load or decode JSON: \(error)")
        }
    }
}
