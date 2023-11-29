//
//  ViolationDataManager.swift
//  Database Query
//
//  Created by 윤우상 on 11/9/23.
//

import UIKit
import Alamofire
import AlamofireImage

protocol ViolationDataManagerDelegate {
    func didUpdateViolationData(_ violationDataManager: ViolationDataManager, violationData: [TrafficViolation])
    func didFailWithError(error: Error)
}

struct ViolationDataManager {
    
    let baseUrl = "http://172.20.10.2:443/TrafficViolations/"
    
    var apiKey = "y76080482ws984ldj9042gbddsdd472913"
    
    var delegate: ViolationDataManagerDelegate?
    
    func fetchViolationData() {
        let urlString = "\(baseUrl)get_all_record/\(apiKey)"
        performRequest(with: urlString)
    }
    
    
    
    // Get TrafficViolation + CheckPoint join table
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
    
    
    
    // TrafficViolation + CheckPoint 테이블을 json 파싱하는 함수
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
    
    
    // 특정 레코드를 삭제하는 기능
    func deleteViolationData(carNumber: String, violationDate: String, violationTime: String) {
        let urlString = "\(baseUrl)delete/\(carNumber)/\(violationDate)/\(violationTime)/\(apiKey)"
            guard let url = URL(string: urlString) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error: Invalid response from server")
                    return
                }
                print("Successfully deleted car record: \(carNumber)")
            }
            task.resume()
        }
    
    func insertNewCar(car: TrafficViolation, completion: @escaping (Bool) -> Void) {
        let urlString = "http://172.20.10.2:443/TrafficViolations/insert_record\(apiKey)" // 실제 서버의 API 주소로 변경
        let parameters: [String: Any] = [
            "car_number": car.carNumber,
            "overspeed": car.overSpeed,
            "speed_limit": car.speedLimit,
            "location": car.location,
            "violation_time": car.violationTime,
            "violation_date": car.violationDate,
            "image_path": car.imagePath // 이미지 파일 이름
        ]

        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Insertion error: \(error)")
                completion(false)
            }
        }
    }
    
    // 이미지를 업데이트 하기위해 사용되는 함수
    func uploadImageAndGetPath(image: UIImage, completion: @escaping (String?) -> Void) {
        let urlString = "http://172.20.10.2:443/TrafficViolations/upload_image/\(apiKey)" // 실제 서버의 이미지 업로드 API 주소로 변경

        // Alamofire를 사용하여 이미지 업로드
        AF.upload(multipartFormData: { multipartFormData in
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                multipartFormData.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
            }
        }, to: urlString).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let imagePath = json["imagePath"] as? String {
                    completion(imagePath)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }

    // 정보를 수정하기 위한 쿼리를 진행하는 함수
    func updateCarData(car: TrafficViolation, completion: @escaping (Bool) -> Void) {
        let urlString = "http://172.20.10.2:443/TrafficViolations/update_record/\(car.carNumber)/\(car.violationDate)/\(car.violationTime)/\(apiKey)" // 실제 서버의 API 주소로 변경
        
            let parameters: [String: Any] = [
                "car_number": car.carNumber,
                "overspeed": car.overSpeed,
                "speed_limit": car.speedLimit,
                "location": car.location,
                "violation_time": car.violationTime,
                "violation_date": car.violationDate,
                "image_path": car.imagePath
            ]

            AF.request(urlString, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success:
                    completion(true)
                case .failure(let error):
                    print("Update error: \(error)")
                    completion(false)
                }
            }
        }
    

}
extension UIImageView {
    func loadImage(withURL imageURL: URL) {
        self.af.setImage(withURL: imageURL)
    }
}
