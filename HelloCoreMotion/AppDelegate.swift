//
//  AppDelegate.swift
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
import CoreMotion
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // see AladinVC
    var targetIsFromUrl = false        // see processUrl() & AladinVC
    var initialTarget:String = "M31"
    var initialFOV =           5.0
    var initialSurvey =        "P/DSS2/color"
    
    var aladinVC:AladinVC? = nil
    var skyViewVC:SkyViewVC? = nil
    var settingsVC:SettingsVC? = nil

    
//    var heartBeat:Heartbeat? = nil
    var settings:Settings?  = Settings()
    
//    func application(_ application: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
//
//        // Determine who sent the URL.
//        let sendingAppID = options[.sourceApplication]
//        print("source application = \(sendingAppID ?? "Unknown")")
//
//        // Process the URL.
//        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
//            let albumPath = components.path,
//            let params = components.queryItems else {
//                print("Invalid URL or album path missing")
//                return false
//        }
//
//        if let photoIndex = params.first(where: { $0.name == "index" })?.value {
//            print("albumPath = \(albumPath)")
//            print("photoIndex = \(photoIndex)")
//            return true
//        } else {
//            print("Photo index missing")
//            return false
//        }
//    }

    // https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app
//    func application(_ application: UIApplication,
//                     openOLD url: URL,
//                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
//
//        // Determine who sent the URL.
//        let sendingAppID = options[.sourceApplication]
//        print("source application = \(sendingAppID ?? "Unknown")")
//
//        // Process the URL.
//        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
//              let object = components.path,
//              let params = components.queryItems else {
//            print("Invalid URL or album path missing")
//            return false
//        }
//
//        if params.count > 0 {
//            print("the value:")
//            print(params[0].value)
//            self.initialTarget = params[0].value!
//        }
//
//        print(object)
//        print(params)
//        return true
//    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true //xx
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true //xx
    }
    
//    func application(_ application: UIApplication,
//                     continue userActivity: NSUserActivity,
//                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
//    {
//        // Get URL components from the incoming user activity.
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//            let incomingURL = userActivity.webpageURL,
//            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
//            return false
//        }
//
//        // Check for specific URL components that you need.
//        guard let path = components.path,
//        let params = components.queryItems else {
//            return false
//        }
//        print("path = \(path)")
//
//        if let albumName = params.first(where: { $0.name == "albumname" } )?.value,
//            let photoIndex = params.first(where: { $0.name == "index" })?.value {
//
//            print("album = \(albumName)")
//            print("photoIndex = \(photoIndex)")
//            return true
//
//        } else {
//            print("Either album name or photo index missing")
//            return false
//        }
//    }
    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        print("connectingSceneSession now")
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
   // https://stackoverflow.com/questions/58214733/application-continue-useractivity-method-not-called-in-ios-13
    
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        if let userActivity = connectionOptions.userActivities.first {
//            debugPrint("got user activity")
//        }
//    }
//    func scene(_ scene: UIScene,
//               willConnectTo session: UISceneSession,
//               options connectionOptions: UIScene.ConnectionOptions) {
//
//        // Determine who sent the URL.
//        if let urlContext = connectionOptions.urlContexts.first {
//
//            let sendingAppID = urlContext.options.sourceApplication
//            let url = urlContext.url
//            print("source application = \(sendingAppID ?? "Unknown")")
//            print("url = \(url)")
//
//            // Process the URL similarly to the UIApplicationDelegate example.
//        }
            
        /*
         *
         */
    }
    
    
    



