//
//  File.swift
//  
//
//  Created by lmmmowi on 2024/5/21.
//

import Foundation
import GroupActivities
import Combine

@available(iOS 15, macOS 12, tvOS 15, *)
final public class GroupSessionMock<M: GroupActivityMock> : ObservableObject {
    
    public typealias ActivityType = M.ActivityType
    
    public enum State {
        case waiting
        case joined
        case invalidated(reason: any Error)
    }
    
    final public var activity: ActivityType
    var groupSession: GroupSession<ActivityType>?
    
    final public var id: UUID;
    
    @Published final public internal(set) var state: GroupSession<ActivityType>.State
    private var stateCancellable: AnyCancellable?
    
    @Published final public internal(set) var activeParticipants: Set<ParticipantMock>
    private var activeParticipantsCancellable: AnyCancellable?
    
    final public var localParticipant: ParticipantMock {
        get {
            if let mock = SharePlayMockManager.useMock() {
                return ParticipantMock(id: mock.localParticipantId!)
            }
            else {
                return ParticipantMock(id: groupSession!.localParticipant.id)
            }
        }
    }
    
    init(session: GroupSession<ActivityType>) {
        self.activity = session.activity
        self.groupSession = session
        self.id = session.id
        self.state = session.state
        self.activeParticipants = ParticipantMock.pack(session.activeParticipants)
        
        self.stateCancellable = session.$state
            .sink { [weak self] value in
                self?.state = value
            }
        
        self.activeParticipantsCancellable = session.$activeParticipants
            .sink { [weak self] value in
                self?.activeParticipants = ParticipantMock.pack(value)
            }
    }
    
    init(mockActivity: M, sessionId: UUID) {
        self.activity = mockActivity.groupActivity
        self.id = sessionId
        self.state = .waiting
        self.activeParticipants = .init()
    }
    
    final public func join() {
        if let mock = SharePlayMockManager.useMock() {
            mock.join(session: self)
        } else {
            groupSession?.join()
        }
    }
    
    final public func leave() {
        if let mock = SharePlayMockManager.useMock() {
            mock.leave(session: self)
        } else {
            groupSession?.leave()
        }
    }
    
    final public func end() {
        if let mock = SharePlayMockManager.useMock() {
            mock.end(session: self)
        } else {
            groupSession?.end()
        }
    }
}


@available(iOS 15, macOS 12, tvOS 15, *)
extension GroupSessionMock {
    
    public struct Sessions : AsyncSequence {

        public typealias Element = GroupSessionMock<M>
        public typealias AsyncIterator = GroupSessionMock<M>.Sessions.Iterator
        
        private var groupSessions: ActivityType.Sessions?
        private var iterator: Iterator
        
        public var current: Element? {
            get {
                return iterator.current
            }
        }
        
        init(groupSessions: ActivityType.Sessions) {
            self.groupSessions = groupSessions
            self.iterator = Iterator(groupSessions.makeAsyncIterator())
        }
        
        init() {
            self.iterator = Iterator(nil)
        }

        public func makeAsyncIterator() -> GroupSessionMock<M>.Sessions.Iterator {
            return self.iterator
        }
        
        public func add(_ session: GroupSessionMock<M>) {
            self.iterator.add(session)
        }
        
        public func clear() {
            self.iterator.current = nil
        }

        public class Iterator : AsyncIteratorProtocol {
            var iterator: GroupSession<ActivityType>.Sessions.Iterator?
            private var elements : [Element] = []
            var current: Element?
            
            init(_ iterator: GroupSession<ActivityType>.Sessions.Iterator?) {
                self.iterator = iterator
            }
            
            public func next() async -> GroupSessionMock<M>? {
                if var iterator = self.iterator {
                    let session = await iterator.next()
                    return GroupSessionMock(session: session!)
                } else {
                    if let mock = SharePlayMockManager.useMock() {
                        let identifier = ActivityType.activityIdentifier
                        let sessionId = current?.id.uuidString
                        let command = Command.querySession(identifier: identifier, sessionId: sessionId)
                        mock.webSocket?.send(command)
                    }
                    
                    while elements.isEmpty {
                        do {
                            try await Task.sleep(nanoseconds: 1_00_000_000)
                        } catch {
                            print(error)
                        }
                    }
                    return elements.removeFirst()
                }
            }
            
            func add(_ element: Element) {
                self.current = element
                self.elements.append(element)
            }

            public typealias Element = GroupSessionMock<M>
        }
    }
}

enum SessionError: Error {
    case leave(String)
    case end(String)
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension SharePlayMockManager {
    
    func join<T: GroupActivityMock>(session: GroupSessionMock<T>) {
        let identifier = T.ActivityType.activityIdentifier
        let sessionId = session.id.uuidString
        
        if useMultipeerConnectivity {
//            connection.joinSession()
        } else {
            let command = Command.joinSession(identifier: identifier, sessionId: sessionId)
            webSocket?.send(command)
        }
    }
    
    func leave<T: GroupActivityMock>(session: GroupSessionMock<T>) {
        let identifier = T.ActivityType.activityIdentifier
        let sessionId = session.id.uuidString
        
        let command = Command.leaveSession(identifier: identifier, sessionId: sessionId)
        webSocket?.send(command)
    }
    
    func end<T: GroupActivityMock>(session: GroupSessionMock<T>) {
        let identifier = T.ActivityType.activityIdentifier
        let sessionId = session.id.uuidString
        
        let command = Command.endSession(identifier: identifier, sessionId: sessionId)
        webSocket?.send(command)
    }
}
