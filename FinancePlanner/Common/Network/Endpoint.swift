//
//  Endpoint.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

let URL = "http://45.95.235.40:5000/api/"

protocol Endpoint {
    var path: String { get }
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
}
