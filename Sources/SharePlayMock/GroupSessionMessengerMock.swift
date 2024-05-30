//
//  File.swift
//  
//
//  Created by lmmmowi on 2024/5/22.
//

import Foundation
import GroupActivities

@available(iOS 15, macOS 12, tvOS 15, *)
public class GroupSessionMessengerMock {
    
    private var activityIdentifier: String
    private var sessionId: UUID
    var messenger: GroupSessionMessenger?
    
    public init<Activity>(session: GroupSessionMock<Activity>) where Activity : GroupActivityMock {
        self.activityIdentifier = Activity.ActivityType.activityIdentifier
        self.sessionId = session.id
        
        if let session = session.groupSession {
            self.messenger = GroupSessionMessenger(session: session)
        }
    }
    
    final public func send<Message>(_ value: Message, to participants: Participants = .all) async throws where Message : Decodable, Message : Encodable {
        if let mock = SharePlayMockManager.useMock() {
            var participantIds: [String]? = nil
            if case .only(let set) = participants {
                participantIds = set.map({ mock in
                    mock.id.uuidString
                })
            }
            mock.sendMessage(value, activityIdentifier: activityIdentifier, sessionId: sessionId, participantIds: participantIds)
        } else {
            if let messenger = self.messenger {
                try await messenger.send(value, to: ParticipantMock.toRaw(participants))
            }
        }
    }
    
    final public func send(_ value: Data, to participants: Participants = .all) async throws {
        if let messenger = self.messenger {
            try await messenger.send(value, to: ParticipantMock.toRaw(participants))
        }
    }
    
    final public func messages<Message>(of type: Message.Type) -> GroupSessionMessengerMock.Messages<Message> where Message : Decodable, Message : Encodable {
        if let messenger = self.messenger {
            let messages = messenger.messages(of: type)
            return GroupSessionMessengerMock.Messages<Message>(messages: messages)
        }
        else {
            return MessageReceiverRegistry.instance.get(activityIdentifier: activityIdentifier, of: type)
        }
    }

    final public func messages(of type: Data.Type) -> GroupSessionMessenger.Messages<Data> {
        return messenger!.messages(of: type)
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
class MessageReceiverRegistry {
    
    static let instance = MessageReceiverRegistry()
    
    var map: [String: MessageReceiver] = [:]
    private let lock = NSLock()
    
    func get<Message: Codable>(activityIdentifier: String, of type: Message.Type) -> GroupSessionMessengerMock.Messages<Message> {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = String(describing: Message.Type.self)
        let key = activityIdentifier + "_" + typeName
        if !map.keys.contains(key) {
            let messages = GroupSessionMessengerMock.Messages<Message>()
            map[key] = messages
        }
        
        return map[key] as! GroupSessionMessengerMock.Messages<Message>
    }
    
    func get(activityIdentifier: String, of typeName: String) -> MessageReceiver? {
        lock.lock()
        defer { lock.unlock() }
        
        let key = activityIdentifier + "_" + typeName
        return map[key]
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
protocol MessageReceiver {
    func receive(message: String, participant: ParticipantMock)
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension GroupSessionMessengerMock {

    public struct MockMessageContext {
        public var source: ParticipantMock
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension GroupSessionMessengerMock {
    
    public struct Messages<Message> : AsyncSequence, MessageReceiver where Message : Codable {
        
        public typealias Element = (Message, MockMessageContext)

        private var messages: GroupSessionMessenger.Messages<Message>?
        private var iterator: Iterator
        
        init(messages: GroupSessionMessenger.Messages<Message>) {
            self.messages = messages
            self.iterator = Iterator(messages.makeAsyncIterator())
        }
        
        init() {
            self.iterator = Iterator(nil)
        }
        
        public func makeAsyncIterator() -> Messages<Message>.Iterator {
            return self.iterator
        }
        
        public func receive(message: String, participant: ParticipantMock) {
            if let m = MessageCodec.decode(message, type: Message.self) {
                let element = (m, MockMessageContext(source: participant))
                self.iterator.add(element)
            }
        }

        public class Iterator : AsyncIteratorProtocol {
            
            var iterator: GroupSessionMessenger.Messages<Message>.Iterator?
            private var elements : [Element] = []
            
            init(_ iterator: GroupSessionMessenger.Messages<Message>.Iterator? = nil) {
                self.iterator = iterator
            }
            
            public func next() async -> Messages<Message>.Element? {
                if var iterator = self.iterator {
                    let element = await iterator.next()!
                    return (element.0, MockMessageContext(source: ParticipantMock.pack(element.1.source)))
                }
                else {
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
                self.elements.append(element)
            }

            public typealias Element = Messages<Message>.Element
        }

        public typealias AsyncIterator = Messages<Message>.Iterator
    }
}

struct MessageCodec {
    static func encode<Message: Codable>(_ value: Message) -> String {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(value)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
        }
        return ""
    }
    
    static func decode<Message: Codable>(_ jsonString: String, type: Message.Type) -> Message? {
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

@available(iOS 15, macOS 12, tvOS 15, *)
extension SharePlayMockManager {

    func sendMessage<Message>(_ value: Message, activityIdentifier: String, sessionId: UUID, participantIds: [String]?) where Message: Codable {
        let messageTypeName = String(describing: Message.Type.self)
        let messageValue = MessageCodec.encode(value)
        let command = Command.sendMessage(identifier: activityIdentifier,
                                          sessionId: sessionId.uuidString,
                                          source: localParticipantId!.uuidString,
                                          messageTypeName: messageTypeName,
                                          messageValue: messageValue,
                                          participantIds: participantIds)
        webSocket?.send(command)
    }
}
