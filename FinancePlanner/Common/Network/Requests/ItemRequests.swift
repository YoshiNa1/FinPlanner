//
//  ItemRequests.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation
import Alamofire

class ItemRequests {
    private var requestManager: RequestManager {
        return RequestManager.instance
    }

    private func sendRequest(_ endpoint: ItemEndpoint, completion: @escaping (NEItem?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }
    
    private func sendRequest(_ endpoint: ItemEndpoint, completion: @escaping ([NEItem]?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }
    
    func create(item: NEItem, completion: @escaping (NEItem?, Error?) -> Void) {
        sendRequest(.create(item: item), completion: completion)
    }
    
    func update(uuid: String, item: NEItem, completion: @escaping (NEItem?, Error?) -> Void) {
        sendRequest(.update(uuid: uuid, item: item), completion: completion)
    }
    
    func get(uuid: String, completion: @escaping (NEItem?, Error?) -> Void) {
        sendRequest(.get(uuid: uuid), completion: completion)
    }
    
    func getAll(completion: @escaping ([NEItem]?, Error?) -> Void) {
        sendRequest(.getAll, completion: completion)
    }
    
    func delete(uuid: String, completion: @escaping (NEItem?, Error?) -> Void) {
        sendRequest(.delete(uuid: uuid), completion: completion)
    }
    
}
