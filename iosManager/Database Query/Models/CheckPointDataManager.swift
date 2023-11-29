//
//  CheckPointDataManager.swift
//  Database Query
//
//  Created by 윤우상 on 11/28/23.
//

import Foundation

protocol CheckPointDataManagerDelegate {
    func didUpdateCheckPointData(_ CheckPointDataManager: CheckPointDataManager, checkPointData: [CheckPoint])
    func didFailWithError(error: Error)
}

struct CheckPointDataManager{
    
    let baseUrl = "http://172.20.10.2:443//CheckPoint/"
    var apiKey = "y76080482ws984ldj9042gbddsdd472913"
    
    var delegate: CheckPointDataManagerDelegate?
    
    func fetchDroneTowerData(){
        let urlString = "\(baseUrl)get_all_record/\(apiKey)"
        performRequest(with: urlString)
    }
    
    // CheckPoint 테이블 가지고 오기
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.delegate?.didFailWithError(error: error)
                return
            }
            if let safeData = data {
                if let checkPoint = self.parseJSON(safeData) {
                    self.delegate?.didUpdateCheckPointData(self, checkPointData: checkPoint)
                }
            }
        }
        task.resume()
        }
    }
    
    // CheckPoint 테이블을 json 파싱하는 함수
    func parseJSON(_ data: Data) -> [CheckPoint]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([CheckPoint].self, from: data)
            return decodedData
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
