//
//  NEItem.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

struct NEItem: Decodable {
    let uuid: String
    let userUuid: String
    let type: String
    let isIncome: Bool
    let name: String
    let description: String
    let category: String
    let amount: Double
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case userUuid
        case type
        case isIncome
        case name
        case description
        case category
        case amount
        case currency
        case createdAt
        case updatedAt
    }
}
