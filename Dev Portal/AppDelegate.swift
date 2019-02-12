//
//  AppDelegate.swift
//  Dev Portal
//
//  Created by Roger Lee on 8/2/19.
//  Copyright © 2019 Roger Lee. All rights reserved.
//

import UIKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.scheme == "devportal") {
            return openURL(url)
        }
        return false
    }

    func openURL(_ url:URL) -> Bool {
        
        //let relativePath = url.pathComponents.last
        //let absoluteString = url.absoluteString
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let tabVC = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
            tabVC.selectedIndex = 0;
            
            let navVC = tabVC.viewControllers![0] as! UINavigationController
            
            let safariVC = navVC.topViewController?.presentedViewController as! SFSafariViewController
            safariVC.dismiss(animated: false, completion: nil)
            
            let firstVC = navVC.topViewController as! FirstViewController
            var linkString = URLComponents(string: url.absoluteString)
            
            var parameters = [String: String]()
            for item in (linkString?.queryItems)! {
                parameters[item.name] = item.value
            }
            
            firstVC.setLink(url.absoluteString, code: parameters["code"]!, state: parameters["state"]!)
        }
        
        return true
    }
}

