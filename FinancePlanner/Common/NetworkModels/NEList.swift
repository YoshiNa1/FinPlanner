//
//  NEList.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

struct NEList: Decodable {
    let uuid: String
    let userUuid: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case userUuid
        case content
    }
}
