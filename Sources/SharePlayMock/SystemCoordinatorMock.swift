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

        public static func == (lhs: SystemCoordinatorMock.ParticipantState, rhs: SystemCoordinatorMock.ParticipantState) -> Bool {
            if SharePlayMockManager.useMock() != nil {
                return lhs.isSpatial == rhs.isSpatial
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
