//
//  SceneDelegate.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let neReachability = NEReachability()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
//        PreferencesStorage.shared.clearSettings()
        let storageEmail = PreferencesStorage.shared.email
        let accessToken = PreferencesStorage.shared.accessToken
        if storageEmail.isEmpty {
            self.showPage(with: "loginVC")
        } else {
            if accessToken.isEmpty {
                DataManager.instance.isUserExist(storageEmail) { exists, error in
                    if let error = error {
                        self.showLoginPage(with: error)
                        return
                    }
                    self.showPage(with: exists ? "signInVC" : "signUpVC")
                }
            }
            else {
                DataManager.instance.getProfile(completion: { profile, error in
                    if let error = error {
                        self.showLoginPage(with: error)
                        return
                    }
                    
                    if let profile = profile, PreferencesStorage.shared.currencies.isEmpty {
                        let currency = Currency(name: profile.currency, isDefault: true)
                        PreferencesStorage.shared.currencies.append(currency)
                        self.showPage(with: "setupProfileVC")
                    } else {
                        DataManager.instance.syncAllData { error in
                            if let error = error {
                                print("Sync data error: \(error.localizedDescription)")
                            }
                            self.showPage(with: "mainTabbarVC")
                        }
                    }
                })
            }
        }
    }

    func showLoginPage(with error: Error) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "loginVC")
        window?.makeKeyAndVisible()
        window?.rootViewController = viewController
//        DispatchQueue.main.async {
//            viewController.showAlert(message: error.localizedDescription)
//        }
    }
    
    func showPage(with identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: identifier)
        window?.makeKeyAndVisible()
        window?.rootViewController = viewController
    }
    
    func changeRootViewController(with identifier: String) {
        guard let window = self.window else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: identifier)
        window.makeKeyAndVisible()
        window.rootViewController = viewController
        
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [.transitionCrossDissolve],
                          animations: nil,
                          completion: nil)
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
        neReachability.start()
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
        neReachability.stop()
    }


}

