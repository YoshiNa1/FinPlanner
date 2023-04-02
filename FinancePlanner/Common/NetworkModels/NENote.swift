//
//  NENote.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import Alamofire

struct NENote: Decodable {
    let id: Int
    let userUuid: String
    let date: Date
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userUuid
        case date
        case content
    }
}
