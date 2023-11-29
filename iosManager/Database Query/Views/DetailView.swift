//
//  DetailView.swift
//  Database Query
//
//  Created by 윤우상 on 11/5/23.
//

import UIKit
import Alamofire
import AlamofireImage


class DetailView: UIView {
    
    var dataManager = CheckPointDataManager()
    var checkPoints: [CheckPoint] = [] // CheckPoint 데이터
    let locationPicker = UIPickerView()
    var isEditMode = true
    
    //MARK: - 멤버 저장속성 구현
    // 멤버 데이터가 바뀌면 ===> didSet(속성감시자) 실행
    // 속성감시자도 (저장 속성을 관찰하는) 어쨌든 자체는 메서드임
    var car: TrafficViolation? {
        didSet {
            UIView.performWithoutAnimation{
                guard let car = car else {
                    // 멤버가 없으면 (즉, 새로운 멤버를 추가할 때의 상황)
                    // 멤버가 없으면 버튼을 "SAVE"라고 설정
                    saveButton.setTitle("SAVE", for: .normal)
                    return
                }
                
                // 멤버가 있으면
                carNumberTextField.text = car.carNumber
                overSpeedTextField.text = String(car.overSpeed)
                bustSpeedTextField.text = String(car.speedLimit)
                positionTextField.text = car.location
                timeTextField.text = car.violationTime
                dateTextField.text = car.violationDate
                
                // 이미지 로드
                let url = URL(string: car.imagePath)
                loadImageAsync(from: url!) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.mainImageView.image = image ?? UIImage(named: "defaultImage")
                    }
                }
            }
        }
    }

    func getInputData() -> (carNumber: String, overSpeed: Int, speedLimit: Int, location: String, violationTime: String, violationDate: String)? {
        // 이미지 제외한 다른 데이터를 가져옵니다.
        guard let carNumber = carNumberTextField.text,
              let overSpeed = Int(overSpeedTextField.text ?? ""),
              let speedLimit = Int(bustSpeedTextField.text ?? ""),
              let location = positionTextField.text,
              let violationTime = timeTextField.text,
              let violationDate = dateTextField.text else {
            return nil
        }
        return (carNumber, overSpeed, speedLimit, location, violationTime, violationDate)
    }
    
    func loadImageAsync(from url: URL, completion: @escaping (UIImage?) -> Void) {
        print("Loading image from URL: \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }
            if let data = data {
                completion(UIImage(data: data))
            } else {
                print("No data received for image")
                completion(nil)
            }
        }.resume()
    }

    
    //MARK: - UI생성
    
    // 이미지 뷰
    let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 이미지뷰를 삽입할 컨테이너뷰
    lazy var imageContainView: UIView = {
        let view = UIView()
        view.addSubview(mainImageView)
        //view.backgroundColor = .yellow
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 차량번호 레이블
    let carNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "차량번호"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 차량번호 텍스트필드
    let carNumberTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 22
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearsOnBeginEditing = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 차량번호 스택뷰 (레이블, 텍스트필드)
    lazy var carNumberStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [carNumberLabel, carNumberTextField])
        stackView.spacing = 5 // 간격
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 단속속도 레이블
    let bustSpeedLabel: UILabel = {
        let label = UILabel()
        label.text = "단속속도"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 단속속도 텍스트필드
    let bustSpeedTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 22
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearsOnBeginEditing = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 단속속도 스택뷰 (레이블, 텍스트필드)
    lazy var bustSpeedStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bustSpeedLabel, bustSpeedTextField])
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 초과속도(기준) 레이블
    let overSpeedLabel: UILabel = {
        let label = UILabel()
        label.text = "초과속도"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 초과속도(기준) 텍스트필드
    let overSpeedTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 22
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearsOnBeginEditing = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 초과속도 스택뷰 (레이블, 텍스트필드)
    lazy var overSpeedStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [overSpeedLabel, overSpeedTextField])
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 위치 레이블
    let positionLabel: UILabel = {
        let label = UILabel()
        label.text = "위       치"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 위치 텍스트필드
    let positionTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 22
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearsOnBeginEditing = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 위치 스택뷰 (레이블, 텍스트필드)
    lazy var postitionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [positionLabel, positionTextField])
        stackView.spacing = 5 // 간격
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 날짜 레이블
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "날       짜"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 날짜 텍스트필드
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 22
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearsOnBeginEditing = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 날짜 스택뷰 (레이블, 텍스트필드)
    lazy var dateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, dateTextField])
        stackView.spacing = 5 // 간격
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 시간 레이블
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "시       간"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 시간 텍스트필드
    let timeTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 22
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearsOnBeginEditing = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 시간 스택뷰
    lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, timeTextField])
        stackView.spacing = 5 // 간격
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 저장 버튼
    let saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .systemGreen
        button.setTitle("UPDATE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.frame.size.height = 50
        button.clipsToBounds = true
        button.layer.cornerRadius = 7
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 스택뷰
    lazy var stackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [imageContainView, carNumberStackView, bustSpeedStackView, overSpeedStackView ,postitionStackView, dateStackView, timeStackView, saveButton]) // 수정된 부분
        stview.spacing = 15
        stview.axis = .vertical
        stview.distribution = .fill
        stview.alignment = .fill
//        stview.backgroundColor = .gray
        stview.translatesAutoresizingMaskIntoConstraints = false
        return stview
    }()
    
    var stackViewTopConstraint: NSLayoutConstraint!
    
    //MARK: - 생성자 설정

    // tableViewCell 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupStackView()
        setupNotification()
        setTextFieldDelegates()
        setupLocationPicker()
        dataManager.fetchDroneTowerData()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTextFieldDelegates() {
        carNumberTextField.delegate = self
        dateTextField.delegate = self
        timeTextField.delegate = self
        positionTextField.delegate = self
        bustSpeedTextField.delegate = self
        dataManager.delegate = self
    }

    private func setupLocationPicker() {
        locationPicker.delegate = self
        locationPicker.dataSource = self
        positionTextField.inputView = locationPicker // 위치 텍스트 필드에 UIPickerView 설정
    }
    
    func setCheckPoints(_ checkPoints: [CheckPoint]) {
            self.checkPoints = checkPoints
            locationPicker.reloadAllComponents()
        }
    //MARK: - UI설정
    func setcarNumberTextField(){
        carNumberTextField.delegate = self
        dateTextField.delegate = self
        timeTextField.delegate = self
        positionTextField.delegate = self
        bustSpeedTextField.delegate = self
    }
    
    // stackView를 tableViewCell에 추가하는 메서드
    func setupStackView() {
        self.addSubview(stackView)
    }
    
    //MARK: - 노티피케이션 셋팅
    
    func setupNotification() {
        // 노티피케이션의 등록 ⭐️
        // (OS차원에서 어떤 노티피케이션이 발생하는지 이미 정해져 있음)
        NotificationCenter.default.addObserver(self, selector: #selector(moveUpAction), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveDownAction), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 오토레이아웃 변동시 바로 적용
    override func updateConstraints() {
        super.updateConstraints()
        setConstrains()
    }

    
    // stackView 및 stackView 내에 포함되는 오브젝트들에 대한 Autolayout 설정
    func setConstrains() {
        stackViewTopConstraint = stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10)
        // 오토레이아웃 활성화 목록
        NSLayoutConstraint.activate([
            
            // stackView 설정
            stackViewTopConstraint,
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20), // stackView leadingAnchor
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20), // stackView trailingAnchor
            
            
            // 각 스택뷰(레이블 + 텍스트필드) 속성 변경
            carNumberLabel.widthAnchor.constraint(equalToConstant: 70),
            bustSpeedLabel.widthAnchor.constraint(equalToConstant: 70),
            overSpeedLabel.widthAnchor.constraint(equalToConstant: 70),
            positionLabel.widthAnchor.constraint(equalToConstant: 70),
            dateLabel.widthAnchor.constraint(equalToConstant: 70),
            timeLabel.widthAnchor.constraint(equalToConstant: 70),
            
            // 이미지 뷰 설정
            mainImageView.heightAnchor.constraint(equalToConstant: 180),
            mainImageView.widthAnchor.constraint(equalToConstant: 320),
            mainImageView.centerXAnchor.constraint(equalTo: imageContainView.centerXAnchor),
            mainImageView.centerYAnchor.constraint(equalTo: imageContainView.centerYAnchor),
            
            
            
            // 이미지 뷰가 들어있는 컨테이너뷰 설정
            imageContainView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        
    }

    //MARK: - 키보드가 나타날때와 내려갈때의 애니메이션 셋팅
    
    @objc func moveUpAction() {
        if let constraint = stackViewTopConstraint {
            constraint.constant = -60
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }

    @objc func moveDownAction() {
        if let constraint = stackViewTopConstraint {
            constraint.constant = 10
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    //MARK: - 소멸자 구현
    
    deinit {
        // 노티피케이션의 등록 해제 (해제안하면 계속 등록될 수 있음) ⭐️
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: - 텍스트필드 델리게이트 구현

extension DetailView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == positionTextField {
                textField.inputView = locationPicker
            }
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if isEditMode && (textField == carNumberTextField || textField == dateTextField || textField == timeTextField || textField == positionTextField || textField == bustSpeedTextField)   {
            return false
        }
        return true
    }
}
extension DetailView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return checkPoints.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return checkPoints[row].location
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLocation = checkPoints[row]
        positionTextField.text = selectedLocation.location
        bustSpeedTextField.text = String(selectedLocation.speed_limit)
    }
}
extension DetailView: CheckPointDataManagerDelegate {
    func didUpdateCheckPointData(_ CheckPointDataManager: CheckPointDataManager, checkPointData: [CheckPoint]) {
        self.checkPoints = checkPointData
        print(self.checkPoints)
    }
    
    func didFailWithError(error: Error) {
        
    }
    
    
}
