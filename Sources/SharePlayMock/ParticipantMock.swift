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
    public let raw: Participant?
    public var hashValue: Int { 0 }
    
    public init(id: UUID, raw: Participant? = nil) {
        self.id = id
        self.raw = raw
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
        return ParticipantMock(id: participant.id, raw: participant)
    }
}

extension ParticipantMock {
    static func toRaw(_ participants: Participants) -> GroupActivities.Participants {
        switch participants {
        case.only(let set):
            let arr = set.map { mock in
                mock.raw!
            }
            return .only(Set(arr))
        default:
            return .all
        }
    }
}

public enum Participants {

    case all

    case only(Set<ParticipantMock>)
}
