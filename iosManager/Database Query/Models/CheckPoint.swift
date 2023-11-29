//
//  CheckPoint.swift
//  Database Query
//
//  Created by 윤우상 on 11/28/23.
//

import Foundation

struct CheckPoint: Codable{
    var location: String
    var lat: Double
    var lon: Double
    var speed_limit: Int
}
