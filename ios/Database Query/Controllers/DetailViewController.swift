//
//  DetailViewController.swift
//  Database Query
//
//  Created by 윤우상 on 10/25/23.
//

import UIKit


final class DetailViewController: UIViewController {

    // MVC패턴을 위한 따로만든 뷰
    let detailView = DetailView()
    
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
        
    }
    
    private func setupData() {
        detailView.car = car
    }
    
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

    
    func setupButtonAction() {
        detailView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    
    @objc func saveButtonTapped() {
        print("saveButtonTapped")
        
        // 네비게이션 컨트롤러를 가져옵니다.
        if let navigationController = self.navigationController {
            // 현재 화면을 pop하여 뒤로 가기를 실행합니다.
            navigationController.popViewController(animated: true)
        }
    }

}
