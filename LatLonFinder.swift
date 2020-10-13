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
        
        switch(CLLocationManager.authorizationStatus()) {
        case .restricted,.denied:
            delegate?.locationIsNotAvailable()
            break
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
        once = true
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(status) {
        case .notDetermined:
            break
        
        case .restricted,.denied:
            delegate?.locationIsNotAvailable()
            break
        
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.startUpdatingLocation()
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
