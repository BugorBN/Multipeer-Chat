//
//  PermitionRequest.swift
//  Multipeer Chat
//
//  Created by Boris Bugor on 03/08/2023.
//

import Foundation
import MultipeerConnectivity

struct PermitionRequest: Identifiable {
    let id = UUID()
    let peerId: MCPeerID
    let onRequest: (Bool) -> Void
}
