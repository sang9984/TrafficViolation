//
//  MapDetailViewController.swift
//  Database Query
//
//  Created by 윤우상 on 11/10/23.
//

import UIKit

class MapDetailViewController: UIViewController {
    
    
    var selectedLocation: String?
    var violationData: [TrafficViolation] = []
    
    
    // 테이블 뷰 인스턴스 생성
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃 사용
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView() // 테이블 뷰 설정 메서드 호출
        setupNaviBar()
    }

    // 테이블 뷰 설정 메서드
    func setupTableView() {
        view.addSubview(tableView) // 뷰에 테이블 뷰 추가
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "MapViewCell")
        
        // 테이블 뷰 오토레이아웃 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupUI(){
        view.backgroundColor = .white
    }
    
    func setupNaviBar() {
        title = "차량 목록"
        
        // 네비게이션바 설정관련
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()  // 불투명으로
        appearance.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
}
// MARK: - UITableViewDataSource
extension MapDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 여기서는 ViolationCars 배열의 길이를 반환합니다.
        return violationData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 셀을 생성하고 구성합니다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath)
        let violation = violationData[indexPath.row]
        cell.textLabel?.text = violation.carNumber
//        let car = ViolationData[indexPath.row]
        // 예시: cell.textLabel?.text = car.carNumber
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MapDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        
        let currentCar = violationData[indexPath.row]
        detailVC.car = currentCar
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
