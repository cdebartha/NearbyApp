//
//  SceneDelegate.swift
//  NearbyApp
//
//  Created by Debartha Chakraborty on 11/05/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        let placesService = DefaultNearbyPlacesService()
        let locationManager = LocationManager()
        let viewModel = DefaultNearbyPlacesViewModel(placesService: placesService, locationManager: locationManager)
        let viewController = ViewController.make(with: viewModel)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window
    }


}

