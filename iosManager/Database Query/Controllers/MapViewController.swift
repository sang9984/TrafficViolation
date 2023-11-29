//
//  mapViewController.swift
//  Database Query
//
//  Created by 윤우상 on 10/19/23.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // 변수선언
    var mapView: MKMapView!
    var locationManager: CLLocationManager? = nil
    var violationData: [TrafficViolation] = []
    var checkPointData: [CheckPoint] = []
    var locationButton: UIButton!
    var dataManager = ViolationDataManager()
    var dataManager2 = CheckPointDataManager()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            setupMap()
            setupLocation()
            setupNaviBar()
            setupLocationButton() // 위치 버튼 설정 함수 호출 추가
            locationManager?.delegate = self
            dataManager.delegate = self
            dataManager2.delegate = self
            mapView?.delegate = self
            dataManager.fetchViolationData()
            dataManager2.fetchDroneTowerData()
            
        }
    
    //MARK: - 기본 세팅
    
    func setupNaviBar() {
        title = "맵 뷰"
        
        // 네비게이션바 설정관련
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()  // 불투명으로
        appearance.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // 버튼설정 - 해당 버늩을 클릭하면 내 현재 위치를 중심으로 화면이동
    func setupLocationButton() {
        
        locationButton = UIButton(type: .system) // 변경된 부분
        locationButton.setTitle("내 위치로 이동", for: .normal)
        locationButton.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.clipsToBounds = true
        locationButton.layer.cornerRadius = 7
        locationButton.backgroundColor = .white
        view.addSubview(locationButton)

        NSLayoutConstraint.activate([
            
            locationButton.widthAnchor.constraint(equalToConstant: 100),
            locationButton.heightAnchor.constraint(equalToConstant: 40),
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // 현재 위치를 얻어오는데 필요한 설정
    func setupLocation(){
        locationManager = CLLocationManager()
                
        // 앱을 사용할 때만 위치 정보를 허용할 경우 호출
        locationManager?.requestWhenInUseAuthorization()
        
        // 위치 정보 제공의 정확도를 설정할 수 있다.
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        // 위치 정보를 지속적으로 받고 싶은 경우 이벤트를 시작
        locationManager?.startUpdatingLocation()
        
    }
    
    // 맵 생성 및 세팅
    func setupMap(){
        
        // MKMapView 인스턴스 생성
        mapView = MKMapView(frame: view.bounds)
        mapView.translatesAutoresizingMaskIntoConstraints = false // 기본 제약 설정 해제
        
        // mapView의 Autoresizing을 설정하여 화면 회전 시 크기가 자동으로 조절되게 함
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 현재 위치를 표시
        mapView.showsUserLocation = true

        // mapView를 메인 뷰에 추가
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
               mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           ])
    }

    // 드론 타워의 위치 업데이트 처리
    func setupdroneTowerLocation(){
        
        
        let hanseo = CLLocationCoordinate2D(latitude: 36.6854, longitude: 126.5793)
        let hanseoTower = MKPointAnnotation()
        hanseoTower.coordinate = hanseo
        hanseoTower.title = "충청남도 서산시 해미면 한서대 입구"
        mapView.addAnnotation(hanseoTower)
        
        let haemie = CLLocationCoordinate2D(latitude:  36.7132, longitude: 126.5625)
        let haemieTower = MKPointAnnotation()
        haemieTower.coordinate = haemie
        haemieTower.title = "충청남도 서산시 해미면 해미 IC"
        mapView.addAnnotation(haemieTower)
        
        let seosanRest = CLLocationCoordinate2D(latitude: 36.7387, longitude: 126.5656)
        let seosanRestTower = MKPointAnnotation()
        seosanRestTower.coordinate = seosanRest
        seosanRestTower.title = "충청남도 서산시 서산휴게소"
        mapView.addAnnotation(seosanRestTower)
        
        let sinchang = CLLocationCoordinate2D(latitude: 36.7527, longitude: 126.5691)
        let sinchangTower = MKPointAnnotation()
        sinchangTower.coordinate = sinchang
        sinchangTower.title = "충청남도 서산시 운산면 신창교"
        mapView.addAnnotation(sinchangTower)
        
        let unsan = CLLocationCoordinate2D(latitude: 36.7846, longitude: 126.5654)
        let unsanTower = MKPointAnnotation()
        unsanTower.coordinate = unsan
        unsanTower.title = "충청남도 서산시 운산면 운산터널"
        mapView.addAnnotation(unsanTower)
    }

    // 나의 위치 업데이트 처리
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
//            print(coordinate.latitude)
//            print(coordinate.longitude)
        }
    }
    
    
    //MARK: - objc
    
    // 버튼을 클릭시 화면을 내 위치를 중심으로한 화면으로 이동시키는 기능의 함수
    @objc func centerMapOnUserLocation() {
        if let location = locationManager?.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}

//MARK: - 확장(델리게이트 등)

// 맵 뷰 컨트롤러 델리게이트
// MKMapViewDelegate 메서드
extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let userLocation = view.annotation as? MKUserLocation {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self, error == nil else {
                print("Reverse geocoder error: \(error!.localizedDescription)")
                return
            }

            if let firstPlacemark = placemarks?.first {
                // 완전한 주소 문자열을 구성합니다.
                var addressString = ""
                if let country = firstPlacemark.country {
                    addressString += country
                }
                if let administrativeArea = firstPlacemark.administrativeArea {
                    addressString += " " + administrativeArea
                }
                if let locality = firstPlacemark.locality {
                    addressString += " " + locality
                }
                if let subLocality = firstPlacemark.subLocality {
                    addressString += " " + subLocality
                }
                if let thoroughfare = firstPlacemark.thoroughfare {
                    addressString += " " + thoroughfare
                }
                if let subThoroughfare = firstPlacemark.subThoroughfare {
                    addressString += " " + subThoroughfare
                }

                self.showAddressLabel(view, address: addressString)
            }
        }
        } else {
        // 그 외의 핀을 선택한 경우 기존 로직 수행
        if let annotationSubtitle = view.annotation?.title {
            let mapDetailVC = MapDetailViewController()
            mapDetailVC.violationData = self.violationData.filter { $0.location == annotationSubtitle }
            self.navigationController?.pushViewController(mapDetailVC, animated: true)
                }
            }
        }

    // 주소를 표시하는 레이블 생성 및 설정
    func showAddressLabel(_ annotationView: MKAnnotationView, address: String) {
        let label = UILabel()
        label.text = address
        label.numberOfLines = 0  // 여러 줄 표시를 허용
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.tag = 999

        // 레이블의 내용에 맞게 크기 조정
        label.sizeToFit()

        // 레이블 크기에 여백 추가
        let padding: CGFloat = 10
        let labelWidth = label.frame.width + padding * 2
        let labelHeight = label.frame.height + padding

        // 레이블의 x 위치는 핀의 중앙에 맞추고, y 위치는 핀의 높이만큼 아래에 위치시킵니다.
        let labelX = annotationView.bounds.width / 2 - labelWidth / 2
        let labelY = annotationView.bounds.height

        label.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        annotationView.addSubview(label)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let label = view.viewWithTag(999) {
            label.removeFromSuperview()
        }
    }
}


extension MapViewController: CLLocationManagerDelegate{
    
}

extension MapViewController: ViolationDataManagerDelegate {
    func didUpdateViolationData(_ violationDataManager: ViolationDataManager, violationData: [TrafficViolation]) {
            DispatchQueue.main.async {
                self.violationData = violationData
//                print(violationData)
            }
        }
    
    func didFailWithError(error: Error) {
            DispatchQueue.main.async {
                // Handle the error, show an alert, etc.
            }
        }
}

extension MapViewController: CheckPointDataManagerDelegate {
    func didUpdateCheckPointData(_ CheckPointDataManager: CheckPointDataManager, checkPointData: [CheckPoint]) {
        DispatchQueue.main.async { [self] in
            self.checkPointData = checkPointData
            
            
        }
    }
}
