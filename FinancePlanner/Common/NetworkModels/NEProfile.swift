//
//  NEProfile.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

struct NEProfile: Decodable {
    let uuid: String
    let userUuid: String
    let balance: Double
    let savings: Double
    let currency: String
  
    enum CodingKeys: String, CodingKey {
        case uuid
        case userUuid
        case balance
        case savings
        case currency
    }
}
