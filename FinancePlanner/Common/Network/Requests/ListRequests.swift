//
//  ListRequests.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation
import Alamofire

class ListRequests {
    private var requestManager: RequestManager {
        return RequestManager.instance
    }

    private func sendRequest(_ endpoint: ListEndpoint, completion: @escaping (NEList?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }

    func update(content: [String], completion: @escaping (NEList?, Error?) -> Void) {
        sendRequest(.update(content: content), completion: completion)
    }
    
    func get(completion: @escaping (NEList?, Error?) -> Void) {
        sendRequest(.get, completion: completion)
    }
}
