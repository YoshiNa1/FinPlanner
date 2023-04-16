//
//  NoteRequests.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation
import Alamofire

class NoteRequests {
    private var requestManager: RequestManager {
        return RequestManager.instance
    }

    private func sendRequest(_ endpoint: NoteEndpoint, completion: @escaping (NENote?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }
    private func sendRequest(_ endpoint: NoteEndpoint, completion: @escaping ([NENote]?, Error?) -> Void) {
        requestManager.sendRequest(endpoint, completion: completion)
    }
    
    func create(date: String, content: String, completion: @escaping (NENote?, Error?) -> Void) {
        sendRequest(.create(date: date, content: content), completion: completion)
    }
    
    func update(date: String, content: String, completion: @escaping (NENote?, Error?) -> Void) {
        sendRequest(.update(date: date, content: content), completion: completion)
    }
    
    func get(date: String, completion: @escaping (NENote?, Error?) -> Void) {
        sendRequest(.get(date: date), completion: completion)
    }
    
    func getAll(completion: @escaping ([NENote]?, Error?) -> Void) {
        sendRequest(.getAll, completion: completion)
    }
    
    func delete(date: String, completion: @escaping (NENote?, Error?) -> Void) {
        sendRequest(.delete(date: date), completion: completion)
    }
    
}
