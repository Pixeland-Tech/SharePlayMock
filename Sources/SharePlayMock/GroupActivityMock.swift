//
//  File.swift
//  
//
//  Created by lmmmowi on 2024/5/21.
//

import Foundation
import GroupActivities

@available(iOS 15, macOS 12, tvOS 15, *)
public protocol GroupActivityMock : Decodable, Encodable {
    
    associatedtype ActivityType: GroupActivity
    
    var groupActivity: ActivityType { get }
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension GroupActivityMock {
    
    public typealias Sessions = GroupSessionMock<Self>.Sessions
    
    public static func sessions() -> Self.Sessions {
        if let mock = SharePlayMockManager.useMock() {
            return mock.createSessions(Self.self)
        }
        else {
            return Sessions(groupSessions: ActivityType.sessions())
        }
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension GroupActivityMock {
    
    public func prepareForActivation() async -> GroupActivityActivationResult {
        if let _ = SharePlayMockManager.useMock() {
            return GroupActivityActivationResult.activationPreferred
        }
        else {
            return await groupActivity.prepareForActivation()
        }
    }
    
    public func activate() async throws -> Bool {
        if let mock = SharePlayMockManager.useMock() {
            mock.activate(activity: self)
            return true
        }
        else {
            return try await groupActivity.activate()
        }
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension GroupActivityMock {
    func onSessionDetected(_ sessionId: UUID) {
        let session = GroupSessionMock<Self>(mockActivity: self, sessionId: sessionId)
        Self.sessions().add(session)
    }
    
    func onJoinSession(_ sessionId: UUID) {
        if Self.sessions().current?.id == sessionId {
            Self.sessions().current?.state = .joined
        }
    }
    
    func onLeaveSession(_ sessionId: UUID) {
        if Self.sessions().current?.id == sessionId {
            Self.sessions().current?.state = .invalidated(reason: SessionError.leave("leave"))
            Self.sessions().clear()
        }
    }
    
    func onEndSession(_ sessionId: UUID) {
        if Self.sessions().current?.id == sessionId {
            Self.sessions().current?.state = .invalidated(reason: SessionError.end("end"))
            Self.sessions().clear()
        }
    }
    
    func onParticipantsChanged(_ sessionId: UUID, participantIds: [String]) {
        if Self.sessions().current?.id == sessionId {
            Self.sessions().current?.activeParticipants = ParticipantMock.pack(participantIds)
        }
    }
    
    func onMessage(_ sessionId: UUID, identifier: String, source: String, messageTypeName: String, messageValue: String) {
        if Self.sessions().current?.id == sessionId {
            if let messageReceiver = MessageReceiverRegistry.instance.get(activityIdentifier: identifier, of: messageTypeName) {
                messageReceiver.receive(message: messageValue, participant: ParticipantMock(id: UUID(uuidString: source)!))
            }
        }
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension SharePlayMockManager {
    
    func activate<T: GroupActivityMock>(activity: T) {
        let identifier = T.ActivityType.activityIdentifier
        let data = ActivityCodec.encode(activity)
        
        if useMultipeerConnectivity {
//            connection.startSession(activityIdentifier: identifier, activityData: data)
        }
        else {
            let command = Command.activate(identifier: identifier, activityData: data)
            webSocket?.send(command)
        }
    }
    
    func createSessions<T: GroupActivityMock>(_ type: T.Type) -> GroupSessionMock<T>.Sessions {
        let id = type.ActivityType.activityIdentifier
        groupActivityTypes[id] = type
        
        if !groupSessions.keys.contains(id) {
            groupSessions[id] = GroupSessionMock<T>.Sessions()
        }
        return groupSessions[id] as! GroupSessionMock<T>.Sessions
    }
    
    func register(_ activity: any GroupActivityMock) {
        let identifier = type(of: activity.groupActivity).activityIdentifier
        groupActivities[identifier] = activity
        Logging.info("register MockGroupActivity: \(type(of: activity))")
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
struct ActivityCodec {
    static func encode(_ activity: any GroupActivityMock) -> String {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(activity)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
        }
        return ""
    }
    
    static func decode<T: GroupActivityMock>(_ jsonString: String, type: T.Type) -> T? {
        print(jsonString)
        if let jsonData = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            
            do {
                return try decoder.decode(type, from: jsonData)
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        } else {
            print("Failed to convert JSON string to Data.")
        }
        return nil
    }
}
