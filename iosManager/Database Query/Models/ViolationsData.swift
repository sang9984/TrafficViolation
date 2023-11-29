//
//  CarData.swift
//  Database Query
//
//  Created by 윤우상 on 10/25/23.
//

import UIKit
    
protocol TrafficViolationDelegate: AnyObject {
    func addNewCar(_ car: TrafficViolation)
    func update(_ car: TrafficViolation)
}

struct TrafficViolation: Codable {
    var carNumber: String
    var overSpeed: Int
    var speedLimit: Int
    var location: String
    var violationTime: String
    var violationDate: String
    var imagePath: String

    private enum CodingKeys: String, CodingKey {
        case carNumber = "car_number"
        case overSpeed = "overspeed"
        case speedLimit = "speed_limit"
        case location
        case violationTime = "violation_time"
        case violationDate = "violation_date"
        case imagePath = "image_path"
    }
    
    var releaseDateString: String? {
        // 날짜 포맷 변경
        DateFormatter.convertISO8601String(violationDate, toFormat: "yyyy-MM-dd")
    }
    
    var formattedViolationTime: String? {
        // 시간 포맷 변경
        DateFormatter.convertISO8601String(violationTime, toFormat: "HH:mm:ss")
    }
}

extension DateFormatter {
    static func convertISO8601String(_ dateString: String, toFormat outputFormat: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: dateString) else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = outputFormat
        return formatter.string(from: date)
    }
}



