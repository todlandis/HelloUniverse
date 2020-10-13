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

    // see processUrl() & AladinVC
    // if targetIsFromUrl = true skip getting the zenith()
    var targetIsFromUrl = false
    var initialTarget:String = "M31"
    var initialFOV =           5.0
    var initialSurvey =        "P/DSS2/color"
    
    var aladinVC:AladinVC? = nil
    var skyViewVC:SkyViewVC? = nil
    var settingsVC:SettingsVC? = nil

    
//    var heartBeat:Heartbeat? = nil
    var settings:Settings?  = Settings()
    var macro:Macro = Macro()

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true 
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}
    
    
    



