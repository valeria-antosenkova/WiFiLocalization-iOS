//
//  RoomModel.swift
//  WiFiLocalization
//
//  Created by Valeria Antosenkova on 2025-06-03.
//

import Foundation
struct Room: Identifiable, Hashable, Equatable {
    var id: String { name }  // use name as unique ID
    let name: String
}
