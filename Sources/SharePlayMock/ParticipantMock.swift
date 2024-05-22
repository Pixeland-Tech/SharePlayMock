//
//  File.swift
//  
//
//  Created by lmmmowi on 2024/5/22.
//

import Foundation
import GroupActivities

@available(iOS 15, macOS 12, tvOS 15, *)
public class ParticipantMock : Hashable, Identifiable {
    
    public typealias ID = UUID
    
    public let id: UUID
    public var hashValue: Int { 0 }
    
    init(id: UUID) {
        self.id = id
    }
    
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: ParticipantMock, rhs: ParticipantMock) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func pack(_ ids: [String]) -> Set<ParticipantMock>{
        return Set(ids.map { ParticipantMock(id: UUID(uuidString: $0)!) })
    }
    
    static func pack(_ participants: Set<Participant>) -> Set<ParticipantMock>{
        return Set(participants.map { ParticipantMock.pack($0) })
    }
    
    static func pack(_ participant: Participant) -> ParticipantMock{
        return ParticipantMock(id: participant.id)
    }
}
