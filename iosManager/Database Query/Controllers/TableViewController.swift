//
//  ViewController.swift
//  Database Query
//
//  Created by 윤우상 on 10/16/23.
//

import UIKit

class TableViewController: UIViewController {
    
    // test용 데이터
    
    var violationData: [TrafficViolation] = []
    var searchData: [TrafficViolation] = []
    var resultData: [TrafficViolation] = []
    var dataManager = ViolationDataManager()
    
    
    //MARK: - ui설정
    
    // 테이블뷰
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // 검색 창
    let searchController = UISearchController()
    
     //네비게이션바에 넣기 위한 버튼
    lazy var plusButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        return button
    }()
    
    //MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self // tableView dataSource
        tableView.dataSource = self // tableView Delegate
        searchController.searchBar.delegate = self //searchController Delegate
        dataManager.delegate = self
        
        setupNaviBar()
        setupTableView()
        setupSearchController()
        dataManager.fetchViolationData()
        print(resultData)
        print(violationData)
    }
    
    // 테이블 뷰 리로드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: - 생성자
    
    // 테이블 뷰 세팅
    func setupTableView() {
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        // tableView 자동배치 제거
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // tableView 삽입
        view.addSubview(tableView)
        
        // tableView Autolayout 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
    }
    
    // 서치컨트롤러 세팅
    func setupSearchController(){
        
        // 서치컨트롤러 기본설정
        searchController.searchBar.placeholder = "Search" // 서치바에 기본으로 표시되는 텍스트
        searchController.hidesNavigationBarDuringPresentation = false // 테이블 뷰를 내리는 동안 서치바 숨기기
        searchController.searchBar.autocapitalizationType = .none // 첫글자를 대문자로 변경하는 옵션
        
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "Search"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
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
        
         //네비게이션바 오른쪽 상단 버튼 설정
        self.navigationItem.rightBarButtonItem = self.plusButton
    }
    
    //MARK: - objc 함수

    @objc func plusButtonTapped() {
        let detailVC = DetailViewController()
        detailVC.delegate = self
        detailVC.isEditMode = false
        navigationController?.pushViewController(detailVC, animated: true)
    }

}


//MARK: - 확장자

// tableView DataSource
extension TableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. 데이터 모델에서 해당 데이터 삭제
            let carToDelete = resultData[indexPath.row]
            resultData.remove(at: indexPath.row)
            
            // 2. 테이블 뷰에서 해당 셀 삭제
            tableView.deleteRows(at: [indexPath], with: .fade)

            // 3. 서버에 삭제 요청 보내기 (비동기)
            dataManager.deleteViolationData(carNumber: carToDelete.carNumber, violationDate: carToDelete.violationDate, violationTime: carToDelete.violationTime)
        }
    }
    
    // tableView에 표시할 데이터 행의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.count
    }
    
    // tableView에서 사용할 Cell 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        let violation = resultData[indexPath.row]
        cell.textLabel?.text = violation.carNumber
        
        return cell
    }
}

// tableView Delegate
extension TableViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let detailVC = DetailViewController()
            
            let currentCar = resultData[indexPath.row]
            detailVC.car = currentCar
            detailVC.isEditMode = true  // 수정 모드로 설정
            detailVC.delegate = self
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
    
}

// searchBar Delegate
extension TableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            resultData = searchData
            tableView.reloadData()
        } else {
            resultData = searchData.filter { $0.carNumber.contains(searchText) }
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            resultData = violationData
            tableView.reloadData()
        }
}

    
extension TableViewController: ViolationDataManagerDelegate {
    
    func didUpdateViolationData(_ violationDataManager: ViolationDataManager, violationData: [TrafficViolation]) {
            DispatchQueue.main.async {
                self.searchData = violationData
                self.violationData = violationData
                self.resultData = violationData
                self.tableView.reloadData()
                
            }
        }
    
    func didFailWithError(error: Error) {
            DispatchQueue.main.async {
                // Handle the error, show an alert, etc.
            }
        }
    
}

extension TableViewController: DetailViewControllerDelegate {
    func didAddNewCar(car: TrafficViolation) {
        DispatchQueue.main.async {
            self.violationData.append(car)
            self.resultData = self.violationData
            self.tableView.reloadData()
        }
    }

    func didUpdateCar(car: TrafficViolation) {
        DispatchQueue.main.async {
            if let index = self.violationData.firstIndex(where: { $0.carNumber == car.carNumber }) {
                self.violationData[index] = car
                self.resultData = self.violationData
                self.tableView.reloadData()
            }
        }
    }
}

