//
//  File.swift
//  
//
//  Created by lmmmowi on 2024/5/21.
//

import Foundation

@available(iOS 15, macOS 12, tvOS 15, *)
public class SharePlayMockManager: ObservableObject {
    
    private static let instance = SharePlayMockManager()
    
    @Published public internal(set) var localParticipantId: UUID?
    
    private var enabled = false
    var useMultipeerConnectivity: Bool = false
    
    var groupStateObservers: [GroupStateObserverMock] = []
    var groupActivities: [String : any GroupActivityMock] = [:]
    var groupActivityTypes: [String : any GroupActivityMock.Type] = [:]
    var groupSessions: [String : Any] = [:]
    
    var webSocket: WebSocketConnection?
    
    public static func getInstance() -> SharePlayMockManager {
        return instance
    }
    
    public static func enable(useMultipeerConnectivity: Bool = false) {
        instance.setEnabled(useMultipeerConnectivity)
    }
    
    static func useMock() -> SharePlayMockManager? {
        if instance.enabled {
            return instance
        } else {
            return nil
        }
    }
    
    private func setEnabled(_ useMultipeerConnectivity: Bool) {
        self.enabled = true
        self.useMultipeerConnectivity = useMultipeerConnectivity
        
        groupStateObservers.forEach { item in
            item.setMock()
        }
        
        if useMultipeerConnectivity {
            
        }
        else {
            self.webSocket = WebSocketConnection()
            webSocket?.connect()
        }
    }
}

struct Logging {
    static func info(_ s: String) {
        print("[SharePlayMock] \(s)")
    }
}
