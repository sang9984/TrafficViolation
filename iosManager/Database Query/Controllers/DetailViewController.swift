//
//  DetailViewController.swift
//  Database Query
//
//  Created by 윤우상 on 10/25/23.
//

import UIKit
import PhotosUI

protocol DetailViewControllerDelegate: AnyObject {
    func didAddNewCar(car: TrafficViolation)
    func didUpdateCar(car: TrafficViolation) // 새로 추가된 메소드
}

final class DetailViewController: UIViewController {

    // MVC패턴을 위한 따로만든 뷰
    let detailView = DetailView()
    var dataManager = ViolationDataManager()
    weak var delegate: DetailViewControllerDelegate?
    
    var isEditMode = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataManager.fetchViolationData() // 데이터를 다시 불러옵니다.
    }

    // MVC패턴을 위해서, view교체
    override func loadView() {
        view = detailView
    }
    
    var car: TrafficViolation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 버튼이 유저의 상호작용이 가능하도록 설정
        detailView.saveButton.isUserInteractionEnabled = true
        setupData()
        setupButtonAction()
        setupTapGestures()
        
        if isEditMode {
            print("수정모드 입니다")
            detailView.isEditMode = true
        }else
        {
            detailView.isEditMode = false
            print("삽입모드 입니다")
        }
        
    }
    //MARK: - 디테일뷰 데이터 흐름 설정

    // 데이터 갱신
    private func setupData() {
        detailView.car = car
    }
    
    // 서버를 통해 이미지 url을 처리
    func loadImage(from url: URL, into imageView: UIImageView) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // 에러 처리
                print("Error downloading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
        task.resume()
    }
    
    
    //MARK: - 이미지뷰가 눌렸을때의 동작 설정
    
    // 제스쳐 설정 (이미지뷰가 눌리면, 실행)
    func setupTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchUpImageView))
        detailView.mainImageView.addGestureRecognizer(tapGesture)
        detailView.mainImageView.isUserInteractionEnabled = true
    }
    
    @objc func touchUpImageView() {
        print("이미지뷰 터치")
        setupImagePicker()
    }
    
    func setupImagePicker() {
        // 기본설정 셋팅
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .any(of: [.images, .videos])
        
        // 기본설정을 가지고, 피커뷰컨트롤러 생성
        let picker = PHPickerViewController(configuration: configuration)
        // 피커뷰 컨트롤러의 대리자 설정
        picker.delegate = self
        // 피커뷰 띄우기
        self.present(picker, animated: true, completion: nil)
    }

    //MARK: - 저장버튼 세팅

    func setupButtonAction() {
        detailView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    
    @objc func saveButtonTapped() {
            guard let carData = detailView.getInputData(),
                  let image = detailView.mainImageView.image else {
                showAlert(message: "Data input error")
                return
            }

            dataManager.uploadImageAndGetPath(image: image) { [weak self] imagePath in
                guard let self = self else { return }
                guard let imagePath = imagePath else {
                    self.showAlert(message: "Image upload failed")
                    return
                }

                let car = TrafficViolation(
                    carNumber: carData.carNumber,
                    overSpeed: carData.overSpeed,
                    speedLimit: carData.speedLimit,
                    location: carData.location,
                    violationTime: carData.violationTime,
                    violationDate: carData.violationDate,
                    imagePath: imagePath
                )

                if self.isEditMode {
                    // 수정 모드
                    self.updateCar(car: car)
                } else {
                    // 삽입 모드
                    self.insertNewCar(car: car)
                }
            }
        }

    private func insertNewCar(car: TrafficViolation) {
        dataManager.insertNewCar(car: car) { [weak self] success in
            if success {
                self?.handleInsertionSuccess(car: car)
            } else {
                self?.showAlert(message: "Failed to insert new car record")
            }
        }
    }


    private func updateCar(car: TrafficViolation) {
        dataManager.updateCarData(car: car) { [weak self] success in
            if success {
                self?.handleUpdateSuccess(car: car)
            } else {
                self?.showAlert(message: "Failed to update record")
            }
        }
    }

    private func handleInsertionSuccess(car: TrafficViolation) {
        delegate?.didAddNewCar(car: car)
        navigationController?.popViewController(animated: true)
    }
    
    private func handleUpdateSuccess(car: TrafficViolation) {
        delegate?.didUpdateCar(car: car)
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

}
//MARK: - 피커뷰 델리게이트 설정

extension DetailViewController: PHPickerViewControllerDelegate {
    
    // 사진이 선택이 된 후에 호출되는 메서드
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 피커뷰 dismiss
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    // 이미지뷰에 표시
                    self.detailView.mainImageView.image = image as? UIImage
                }
            }
        } else {
            print("이미지 못 불러왔음!!!!")
        }
    }
}
