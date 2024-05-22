//
//  File.swift
//  
//
//  Created by lmmmowi on 2024/5/22.
//

import Foundation
import MultipeerConnectivity

class ConnectionHolder : NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    let serviceType = "test"
    
    let localPeer: MCPeerID
    var peers: Set<MCPeerID> = Set()
    
    let session: MCSession
    
    var browser: MCNearbyServiceBrowser
    var advertiser: MCNearbyServiceAdvertiser
    
    var delegate: ConnectionDelegate?
    
    var invitationContext: ConnectionContext?
    var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    override init() {
        self.localPeer = MCPeerID(displayName: UUID().uuidString)
        self.session = MCSession(peer: localPeer)
        self.browser = MCNearbyServiceBrowser(peer: localPeer, serviceType: serviceType)
        self.advertiser = MCNearbyServiceAdvertiser(peer: localPeer, discoveryInfo: nil, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        browser.delegate = self
        advertiser.delegate = self
    }
    
    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    func startSession(activityIdentifier: String, activityData: String) {
        let sessionId = UUID()
        let context = ConnectionContext(sessionId: sessionId, activityIdentifier: activityIdentifier, activityData: activityData)
        
        self.peers.forEach { peerId in
            browser.invitePeer(peerId, to: session, withContext: ConnectionContext.encode(context), timeout: TimeInterval.infinity)
        }
        
        delegate?.session(detected: context)
    }
    
    func joinSession() {
        if let invitationHandler = self.invitationHandler {
            invitationHandler(true, self.session)
        }
    }
    
    func send() {
        do {
            let message = "Hello, World!"
            try session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("[Connection] foundPeer \(peerID)")
        peers.insert(peerID)
        print("[Connection] total peers: \(peers.count)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("[Connection] lostPeer \(peerID)")
        peers.remove(peerID)
        print("[Connection] total peers: \(peers.count)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let invitationContext = ConnectionContext.decode(context) {
            print("[Connection] receive invitation from \(peerID) with context \(invitationContext)")
            self.delegate?.session(detected: invitationContext)
            
            self.invitationContext = invitationContext
            self.invitationHandler = invitationHandler
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("[Connection] Connected: \(peerID.displayName)")
            self.send()
            break
        case .connecting:
            print("[Connection] Connecting: \(peerID.displayName)")
            break
        case .notConnected:
            print("[Connection] Not Connected: \(peerID.displayName)")
            break
        @unknown default:
            fatalError("[Connection] Unknown state received: \(state)")
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("[Connection] session didReceive data from \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("[Connection] session didReceive stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("[Connection] session didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        print("[Connection] session didStartReceivingResourceWithName at localURL")
    }
}

protocol ConnectionDelegate {
    func session(detected: ConnectionContext);
}

struct ConnectionContext: Codable {
    let sessionId: UUID
    let activityIdentifier: String
    let activityData: String
    
    static func encode(_ context: ConnectionContext) -> Data? {
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(context)
        } catch {
            print("Failed to encode message: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func decode(_ context: Data?) -> ConnectionContext? {
        if let data = context {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(ConnectionContext.self, from: data)
            } catch {
                print("Failed to decode message: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
