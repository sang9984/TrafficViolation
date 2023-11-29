//
//  SceneDelegate.swift
//  Database Query
//
//  Created by 윤우상 on 10/16/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)


        // 탭바에서 표시할 2개의 viewController를 지정
        let vc1 = TableViewController()
        let vc2 = MapViewController()

        vc1.title = "테이블 뷰"
        vc2.title = "맵 뷰"
        
        // 각 ViewController를 UINavigationController로 래핑
        let tabBarVC = UITabBarController()
        
        // firstNavigationController 설정
        let firstNavigationController = UINavigationController(rootViewController: vc1)
        firstNavigationController.navigationBar.backgroundColor = .white
        
        // secondNavigationController 설정
        let secondNavigationController = UINavigationController(rootViewController: vc2)
        secondNavigationController.navigationBar.backgroundColor = .white
        
        // 탭바에 들어갈 viewController 목록 설정
        tabBarVC.setViewControllers([firstNavigationController, secondNavigationController], animated: true)
        tabBarVC.tabBar.backgroundColor = .white
        
        // 탭바에 들어가는 아이템 설정
        guard let items = tabBarVC.tabBar.items else { return }
        
        items[0].image = UIImage(systemName: "list.bullet")
        items[0].title = "테이블 뷰"
        items[1].image = UIImage(systemName: "paperplane.circle.fill")
        items[1].title = "맵 뷰"
        
        window?.rootViewController = tabBarVC
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

