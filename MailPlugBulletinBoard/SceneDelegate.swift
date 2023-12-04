//
//  SceneDelegate.swift
//  MailPlugBulletinBoard
//
//  Created by 장예지 on 11/28/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let apiService: WebService = WebService()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 새로운 UIWindow 인스턴스 생성
        let window = UIWindow(windowScene: windowScene)
        
        apiService.getBoards { board in
            if let boardId = board?.first?.boardId, let boardTitle = board?.first?.displayName {
                let viewModel = PostListViewModel(id: boardId, title: boardTitle)
                let rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController { code in
                    ViewController(coder: code, viewModel: viewModel)
                }
                
                // 루트 뷰 컨트롤러를 설정하여 윈도우에 할당
                window.rootViewController = UINavigationController(rootViewController: rootViewController!)
                
                // 윈도우를 화면에 표시
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }
}

