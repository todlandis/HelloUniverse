//
//  SceneDelegate.swift
//  Copyright © 2020 Tod Landis. All rights reserved.
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
    }
    
    // https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app
    // loading a url with the app not running comes here
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else {
            return
        }
        
        if let s = connectionOptions.urlContexts.first {
            processURL(s)
        }
    }
    
    // loading a url with the app running comes here
    func scene(_ scene: UIScene,
               openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let s = URLContexts.first {
            processURL(s)
        }
    }
    
    func processURL(_ s:UIOpenURLContext) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("ERROR no appDelegate in openURLContexts")
            return
        }

        // hellouniverse://target?survey?fov
        if let host = s.url.host {
            let hostSpaced = host.replacingOccurrences(of: "_", with: " ")
            appDelegate.targetIsFromUrl = true
            if let aladinVC = appDelegate.aladinVC  {
                aladinVC.searchBar.text = hostSpaced
            }
            appDelegate.initialTarget = hostSpaced
        }
        
        if let query = s.url.query {
            let components = query.components(separatedBy: "?")
            if components.count > 0 {
                appDelegate.initialSurvey =    components[0]
                appDelegate.settings.chooseSurvey(survey: components[0])
                
            }
            if components.count > 1 {
                if let d = Double(components[1]) {
                    appDelegate.initialFOV = d
                }
            }
        }
        
        if let aladin = appDelegate.aladinVC?.aladin {
            aladin.setImageSurvey(survey: appDelegate.initialSurvey)
            aladin.setFov(appDelegate.initialFOV)
            
            aladin.gotoObject(name: appDelegate.initialTarget, completionHandler: {
                (d1,d2,error) in
                DispatchQueue.main.async {
                    appDelegate.aladinVC!.updateLabels()
                }
            })
        }
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

