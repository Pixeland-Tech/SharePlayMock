//
//  SystemCoordinatorMock.swift
//  SharePlayMock
//
//  Created by Xinyi Chen on 8/6/24.
//

import GroupActivities
import Spatial
import SwiftUI

@available(visionOS 1.0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@available(macOS, unavailable)
public class SystemCoordinatorMock {
    
    var raw: SystemCoordinator?
    
    private var configurationMock: SystemCoordinator.Configuration = SystemCoordinator.Configuration()
    final public var configuration: SystemCoordinator.Configuration {
        get {
            if SharePlayMockManager.useMock() != nil {
                return configurationMock
            } else {
                return raw!.configuration
            }
        }
        
        set(value) {
            if SharePlayMockManager.useMock() != nil {
                configurationMock = value
            } else {
                raw!.configuration = value
            }
        }
    }
    
    final public var localParticipantState: SystemCoordinatorMock.ParticipantState {
        get {
            if SharePlayMockManager.useMock() != nil {
                return SystemCoordinatorMock.ParticipantState()
            } else {
                return SystemCoordinatorMock.ParticipantState(raw: raw!.localParticipantState)
            }
        }
    }
    
    final public var localParticipantStates: SystemCoordinatorMock.ParticipantStates {
        get {
            if SharePlayMockManager.useMock() != nil {
                return SystemCoordinatorMock.ParticipantStates()
            } else {
                return SystemCoordinatorMock.ParticipantStates(raw: raw!.localParticipantStates)
            }
        }
    }
    


    public init(raw: SystemCoordinator?) {
        self.raw = raw
    }
    
    @available(visionOS 2.0, *)
    final public func assignRole(_ role: some SpatialTemplateRole) {
        if (SharePlayMockManager.useMock() == nil) {
            raw?.assignRole(role)
        }
    }

    @available(visionOS 2.0, *)
    final public func resignRole() {
        if (SharePlayMockManager.useMock() == nil) {
            raw?.resignRole()
        }
    }
    
}

@available(visionOS 1.0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@available(macOS, unavailable)
extension SystemCoordinatorMock {
    
    final public var groupImmersionStyle: SystemCoordinatorMock.GroupImmersionStyles {
        get {
            if SharePlayMockManager.useMock() != nil {
                return GroupImmersionStyles(raw: nil)
            }
            else {
                return GroupImmersionStyles(raw: raw!.groupImmersionStyle)
            }
        }
    }
    
    public struct GroupImmersionStyles : AsyncSequence {
        
        var raw: SystemCoordinator.GroupImmersionStyles?

        public typealias Element = (any ImmersionStyle)?

        public func makeAsyncIterator() -> SystemCoordinatorMock.GroupImmersionStyles.Iterator {
            return Iterator(raw?.makeAsyncIterator())
        }

        public class Iterator : AsyncIteratorProtocol {
            
            var raw: SystemCoordinator.GroupImmersionStyles.Iterator?
            
            init(_ raw: SystemCoordinator.GroupImmersionStyles.Iterator? = nil) {
                self.raw = raw
            }
            
            public func next() async -> SystemCoordinator.GroupImmersionStyles.Element? {
                if SharePlayMockManager.useMock() != nil {
                    return nil
                } else {
                    return await raw!.next()
                }
            }

            @available(visionOS 1.0, *)
            @available(iOS, unavailable, introduced: 13.0)
            @available(tvOS, unavailable, introduced: 13.0)
            @available(watchOS, unavailable, introduced: 6.0)
            @available(macOS, unavailable, introduced: 10.15)
            public typealias Element = SystemCoordinatorMock.GroupImmersionStyles.Element
        }

        @available(visionOS 1.0, *)
        @available(iOS, unavailable, introduced: 13.0)
        @available(tvOS, unavailable, introduced: 13.0)
        @available(watchOS, unavailable, introduced: 6.0)
        @available(macOS, unavailable, introduced: 10.15)
        public typealias AsyncIterator = SystemCoordinatorMock.GroupImmersionStyles.Iterator
    }
    
    public struct ParticipantState : Equatable {
        
        var raw: SystemCoordinator.ParticipantState?

        public var isSpatial: Bool {
            get {
                if SharePlayMockManager.useMock() != nil {
                    return true
                } else {
                    return raw!.isSpatial
                }
            }
        }

        @available(visionOS 2.0, *)
        public var seat: SystemCoordinatorMock.ParticipantState.Seat? {
            get {
                if SharePlayMockManager.useMock() != nil {
                    return SystemCoordinatorMock.ParticipantState.Seat(raw: nil)
                } else {
                    return SystemCoordinatorMock.ParticipantState.Seat(raw: raw!.seat)
                }
            }
        }

        @available(visionOS 2.0, *)
        public var role: (any SpatialTemplateRole)? {
            if SharePlayMockManager.useMock() != nil {
                return nil
            } else {
                return raw!.role
            }
        }

        public static func == (lhs: SystemCoordinatorMock.ParticipantState, rhs: SystemCoordinatorMock.ParticipantState) -> Bool {
            if SharePlayMockManager.useMock() != nil {
                if #available(visionOS 2.0, *) {
                    return lhs.isSpatial == rhs.isSpatial && lhs.seat == rhs.seat && lhs.role?.roleIdentifier == rhs.role?.roleIdentifier
                } else {
                    return lhs.isSpatial == rhs.isSpatial
                }
            } else {
                return lhs.raw! == rhs.raw!
            }
        }
    }
    
    public struct ParticipantStates : AsyncSequence {
        
        var raw: SystemCoordinator.ParticipantStates?

        public typealias Element = SystemCoordinator.ParticipantState

        public func makeAsyncIterator() -> SystemCoordinatorMock.ParticipantStates.Iterator {
            return Iterator(raw: raw?.makeAsyncIterator())
        }

        public struct Iterator : AsyncIteratorProtocol {
            
            var raw: SystemCoordinator.ParticipantStates.Iterator?

            public mutating func next() async -> SystemCoordinator.ParticipantStates.Element? {
                if SharePlayMockManager.useMock() != nil {
                    return nil
                } else {
                    return await raw!.next()
                }
            }

            @available(visionOS 1.0, *)
            @available(iOS, unavailable, introduced: 13.0)
            @available(tvOS, unavailable, introduced: 13.0)
            @available(watchOS, unavailable, introduced: 6.0)
            @available(macOS, unavailable, introduced: 10.15)
            public typealias Element = SystemCoordinator.ParticipantStates.Element
        }

        @available(visionOS 1.0, *)
        @available(iOS, unavailable, introduced: 13.0)
        @available(tvOS, unavailable, introduced: 13.0)
        @available(watchOS, unavailable, introduced: 6.0)
        @available(macOS, unavailable, introduced: 10.15)
        public typealias AsyncIterator = SystemCoordinatorMock.ParticipantStates.Iterator
    }
}

@available(visionOS 2.0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@available(macOS, unavailable)
extension SystemCoordinatorMock.ParticipantState {
    public struct Seat : Hashable {
        
        var raw: SystemCoordinator.ParticipantState.Seat?

        public var pose: Pose3D {
            get {
                if SharePlayMockManager.useMock() != nil {
                    return Pose3D()
                } else {
                    return raw!.pose
                }
            }
        }

        public var role: (any SpatialTemplateRole)? {
            get {
                if SharePlayMockManager.useMock() != nil {
                    return nil
                } else {
                    return raw!.role
                }
            }
        }

        public static func == (lhs: SystemCoordinatorMock.ParticipantState.Seat, rhs: SystemCoordinatorMock.ParticipantState.Seat) -> Bool {
            if SharePlayMockManager.useMock() != nil {
                return lhs.pose == rhs.pose && lhs.role?.roleIdentifier == rhs.role?.roleIdentifier
            } else {
                return lhs.raw! == rhs.raw!
            }
        }

        public func hash(into hasher: inout Hasher) {
            if (SharePlayMockManager.useMock() == nil) {
                raw!.hash(into: &hasher)
            }
        }

        public var hashValue: Int {
            get {
                if SharePlayMockManager.useMock() != nil {
                    return 0
                } else {
                    return raw!.hashValue
                }
            }
        }
    }
}
