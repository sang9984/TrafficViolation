//
//  ViolationDataManager.swift
//  Database Query
//
//  Created by 윤우상 on 11/9/23.
//

import Foundation
import AlamofireImage

protocol ViolationDataManagerDelegate {
    func didUpdateViolationData(_ violationDataManager: ViolationDataManager, violationData: [TrafficViolation])
    func didFailWithError(error: Error)
}

struct ViolationDataManager {
    
    let baseUrl = "http://172.20.10.3:443/TrafficViolations/get_all_record/"
    var apiKey = "y76080482ws984ldj9042gbddsdd472913"
    
    var delegate: ViolationDataManagerDelegate?
    
    func fetchViolationData() {
        let urlString = "\(baseUrl)\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.delegate?.didFailWithError(error: error)
                return
            }
            if let safeData = data {
                if let violationData = self.parseJSON(safeData) {
                    self.delegate?.didUpdateViolationData(self, violationData: violationData)
                }
            }
        }
        task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> [TrafficViolation]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([TrafficViolation].self, from: data)
            return decodedData
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
extension UIImageView {
    func loadImage(withURL imageURL: URL) {
        self.af.setImage(withURL: imageURL)
    }
}
