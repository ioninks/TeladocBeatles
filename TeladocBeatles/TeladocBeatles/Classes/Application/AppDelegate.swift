//
//  AppDelegate.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    
    let viewModel = AlbumsViewModel(
      initialQuery: "thebeatles",
      dependencies: .init(
        albumService: AlbumService()
      )
    )
    let viewController = AlbumsViewController(viewModel: viewModel)
    self.window?.rootViewController = viewController
    
    self.window?.makeKeyAndVisible()
    
    return true
  }

}

