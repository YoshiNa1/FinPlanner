//
//  NEUser.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

struct NEUser: Decodable {
    let uuid: String
    let email: String
    let password: String
    let isActivated: Bool
    let activationLink: String
  
    enum CodingKeys: String, CodingKey {
        case uuid
        case email
        case password
        case isActivated
        case activationLink
    }
}
