//
//  LatLonFinder.swift
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

import Foundation
import CoreLocation

// never used ... keep for later
public protocol LatLonFinderDelegate : NSObjectProtocol {
    func updateLocation(location:CLLocation)
    func locationIsNotAvailable()
}

class LatLonFinder : NSObject, CLLocationManagerDelegate {
    var delegate:LatLonFinderDelegate? = nil
    let locationManager = CLLocationManager()
    var once = true
    
    func getLocationOnce() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        once = true
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(status) {
        case .notDetermined:
            break
        
        // This application is not authorized to use location services.  Due
        // to active restrictions on location services, the user cannot change
        // this status, and may not have personally denied authorization
        case .restricted:
            delegate?.locationIsNotAvailable()
            break
        
        // User has explicitly denied authorization for this application, or
        // location services are disabled in Settings.
        case .denied:
            delegate?.locationIsNotAvailable()
            break
        
        // User has granted authorization to use their location at any
        // time.  Your app may be launched into the background by
        // monitoring APIs such as visit monitoring, region monitoring,
        // and significant location change monitoring.
        //
        // This value should be used on iOS, tvOS and watchOS.  It is available on
        // MacOS, but kCLAuthorizationStatusAuthorized is synonymous and preferred.
        case .authorizedAlways:
            break
        
        // User has granted authorization to use their location only while
        // they are using your app.  Note: You can reflect the user's
        // continued engagement with your app using
        // -allowsBackgroundLocationUpdates.
        //
        // This value is not available on MacOS.  It should be used on iOS, tvOS and
        // watchOS.
        case .authorizedWhenInUse:
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(once) {
            locationManager.stopUpdatingLocation()
        }
        if let delegate = delegate {
            delegate.updateLocation(location: locations[locations.count-1])
        }
    }
    
}
