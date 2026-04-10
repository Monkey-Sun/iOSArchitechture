//
//  SceneDelegate.swift
//  iOSArchitecture
//
//  Created by 孙俊祥 on 2026/4/8.
//

import UIKit
import AppModuleFacade
import HomeModule
import LoginModule
import NotFoundModule
import ProfileModule
import SettingModule

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var globalRoute: AppNavigationAdaptor?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
       viewInit(windowScene: windowScene)
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

    func viewInit(windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        
        let dependencies = AppDependencies(
            authSession: InMemoryAuthSession(),
            deepLinkRouter: AppDeepLinkMiddleware(),
            notFoundRouteFactory: { originalRoute in
                UnresolvedDeepLinkRoute.notFound(originalRouteType: String(describing: Swift.type(of: originalRoute)))
            }
        )
        
        let adaptor = AppNavigationAdaptor(
            window: window,
            tabs: [
                HomeTabModule(),
                ProfileTabModule(),
                SettingsTabModule(),
            ],
            appModules: [
                LoginModule(),
                NotFoundModule(),
            ],
            dependencies: dependencies,
        )
        adaptor.start()
        globalRoute = adaptor
        self.window = window
    }
}

