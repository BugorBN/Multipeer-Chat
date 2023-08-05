//
//  DeviceFinderViewModel.swift
//  Multipeer Chat
//
//  Created by Boris Bugor on 03/08/2023.
//

import MultipeerConnectivity
import SwiftyChat
import Combine

class DeviceFinderViewModel: NSObject, ObservableObject {
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private let session: MCSession
    private let serviceType = "nearby-devices"

    @Published var permissionRequest: PermitionRequest?
    
    @Published var selectedPeer: PeerDevice? {
        didSet {
            connect()
        }
    }
    @Published var peers: [PeerDevice] = []
    @Published var isAdvertised: Bool = false {
        didSet {
            isAdvertised ? advertiser.startAdvertisingPeer() : advertiser.stopAdvertisingPeer()
        }
    }

    @Published var messages: [MockMessages.ChatMessageItem] = []
    let messagePublisher = PassthroughSubject<MockMessages.ChatMessageItem, Never>()
    var subscriptions = Set<AnyCancellable>()

    func send(draft: ChatMessageKind) {
        guard case let .text(string) = draft else {
            return
        }
        
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        try? session.send(data, toPeers: [joinedPeer.last!.peerId], with: .reliable)

        messagePublisher.send(
            .init(user: MockMessages.sender, messageKind: draft, isSender: true)
        )
    }
    
    @Published var joinedPeer: [PeerDevice] = []
    
    override init() {
        let peer = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peer)
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peer,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        
        super.init()
        
        advertiser.delegate = self
        browser.delegate = self
        session.delegate = self
        
        messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.messages.append($0)
            }
            .store(in: &subscriptions)
    }

    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func finishBrowsing() {
        browser.stopBrowsingForPeers()
    }
    
    func show(peerId: MCPeerID) {
        guard let first = peers.first(where: { $0.peerId == peerId }) else {
            return
        }
        
        joinedPeer.append(first)
    }
    
    private func connect() {
        guard let selectedPeer else {
            return
        }
        
        if session.connectedPeers.contains(selectedPeer.peerId) {
            joinedPeer.append(selectedPeer)
        } else {
            browser.invitePeer(selectedPeer.peerId, to: session, withContext: nil, timeout: 60)
        }
    }
}

extension DeviceFinderViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        permissionRequest = PermitionRequest(
            peerId: peerID,
            onRequest: { [weak self] permission in
                invitationHandler(permission, permission ? self?.session : nil)
            }
        )
    }
}

extension DeviceFinderViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        peers.append(PeerDevice(peerId: peerID))
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peers.removeAll(where: { $0.peerId == peerID })
    }
}

extension DeviceFinderViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let last = joinedPeer.last, last.peerId == peerID, let message = String(data: data, encoding: .utf8) else {
            return
        }

        messagePublisher.send(
            .init(user: MockMessages.sender, messageKind: .text(message), isSender: false)
        )
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
}
