//
//  NetworkReachabilityManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.04.2023.
//

import Foundation
import Alamofire

let connectionStatus = "connectionStatus"

extension Notification.Name {
    static let connectionStatusChanged = Notification.Name("internetConnectionStatusChanged")
}

class NEReachability {
    private var reachabilityManager: NetworkReachabilityManager? = NetworkReachabilityManager()

    var isReachable: Bool {
        switch status {
        case .unknown, .reachable:
            return true
        case .notReachable:
            return false
        }
    }
    
    private var previouslyConnected: Bool = false
    
    var status: NetworkReachabilityManager.NetworkReachabilityStatus {
        return reachabilityManager?.status ?? .unknown
    }

    func start() {
        reachabilityManager?.startListening(onUpdatePerforming: { (status) in
            self.postNotification(status: status)
        })
        self.previouslyConnected = self.isReachable
    }

    func stop() {
        reachabilityManager?.stopListening()
    }
    
    private func postNotification(status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .connectionStatusChanged,
                                            object: self,
                                            userInfo: [connectionStatus: status])
            switch self.status {
            case .reachable, .unknown:
                if self.previouslyConnected == false {
                    self.connectionAppeared()
                }
                self.previouslyConnected = true
            case .notReachable:
                if self.previouslyConnected == true {
                    self.connectionLost()
                }
                self.previouslyConnected = false
            }
        }
    }
    
    func connectionAppeared() {
        DataManager.instance.syncAllData { _ in }
    }

    func connectionLost() {
        DataManager.instance.refreshSyncState()
    }

}
