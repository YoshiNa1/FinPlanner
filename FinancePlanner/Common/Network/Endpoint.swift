//
//  Endpoint.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

let URL = "http://192.168.32.11:5000/api/"

protocol Endpoint {
    var path: String { get }
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
}
