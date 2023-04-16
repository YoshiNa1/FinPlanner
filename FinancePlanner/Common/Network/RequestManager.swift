//
//  RequestManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class RequestManager {
    
    public static var instance: RequestManager = {
        let instance = RequestManager()
        return instance
    }()
    
    private init() { }
    
    func sendRequest(_ endpoint: Endpoint, completion: @escaping (Any?, Error?) -> Void) {
        let queue: DispatchQueue = .main
        let request = request(with: endpoint)
        request.responseJSON { response in
            debugPrint("Response: \(response)")
            let data = response.value
            queue.async { completion(data, response.error) }
        }
    }
    
    func sendRequest<T: ImmutableMappable>(_ endpoint: Endpoint, completion: @escaping (T?, Error?) -> Void) {
        let queue: DispatchQueue = .main
        let request = request(with: endpoint)
        request.responseObject { (response: DataResponse<T, AFError>) in
            debugPrint("Response: \(response)")
            let data = try? response.result.get()
            queue.async { completion(data, response.error) }
        }
    }
    
    func sendRequest<T: ImmutableMappable>(_ endpoint: Endpoint, completion: @escaping ([T]?, Error?) -> Void) {
        let queue: DispatchQueue = .main
        let request = request(with: endpoint)
        request.responseArray { (response:DataResponse<[T], AFError>) in
            debugPrint("Response: \(response)")
            let data = try? response.result.get()
            queue.async { completion(data, response.error) }
        }
    }
    
    private func request(with endpoint: Endpoint) -> Alamofire.DataRequest {
        var request = AF.request(endpoint.path,
                                 method: endpoint.method,
                                 parameters: endpoint.parameters,
                                 encoding: JSONEncoding.default,
                                 headers: endpoint.headers)
        request.validate(statusCode: 200..<600).responseJSON { response in
            let statusCode = response.response?.statusCode
            if statusCode == 403 {
                self.refreshToken(endpoint: endpoint) { _request in
                    request = _request
                }
            }
            
        }
        return request
    }
    
    private func refreshToken(endpoint: Endpoint, completion: @escaping (Alamofire.DataRequest) -> Void) {
        debugPrint("Refreshing token...")
        UserRequests().refresh { user, error in
            if let accessToken = user?.accessToken {
                PreferencesStorage.shared.accessToken = accessToken
            }
            debugPrint("Token refreshed!")
            completion(self.request(with: endpoint))

            if error != nil {
                debugPrint("Trying to refresh token again...")
                self.refreshToken(endpoint: endpoint, completion: completion)
            }
        }
    }
}


