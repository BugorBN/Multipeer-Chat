//
//  PeerDevice.swift
//  Multipeer Chat
//
//  Created by Boris Bugor on 03/08/2023.
//

import Foundation
import MultipeerConnectivity

struct PeerDevice: Identifiable, Hashable {
    let id = UUID()
    let peerId: MCPeerID
}
