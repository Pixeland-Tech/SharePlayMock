//
//  File.swift
//  
//
//  Created by lmmmowi on 2024/5/21.
//

import Foundation
import Combine
import GroupActivities

@available(iOS 15, macOS 12, tvOS 15, *)
final public class GroupStateObserverMock : ObservableObject {

    @Published final public private(set) var isEligibleForGroupSession: Bool
    
    private let groupStateObserver = GroupStateObserver()
    private var cancellable: AnyCancellable?
    
    public init() {
        if let _ = SharePlayMockManager.useMock() {
            print("11")
            self.isEligibleForGroupSession = true
        }
        else {
            self.isEligibleForGroupSession = groupStateObserver.isEligibleForGroupSession
            self.cancellable = groupStateObserver.$isEligibleForGroupSession
                .sink { [weak self] value in
                    self?.isEligibleForGroupSession = value
                }
            
            SharePlayMockManager.getInstance().register(self)
        }
    }
    
    func setMock() {
        print("1122")
        self.isEligibleForGroupSession = true
        self.cancellable = nil
    }
}

@available(iOS 15, macOS 12, tvOS 15, *)
extension SharePlayMockManager {
    
    func register(_ observer: GroupStateObserverMock) {
        groupStateObservers.append(observer)
    }
}
