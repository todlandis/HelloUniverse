//
//  SkyMapVC.swift
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

class SkyViewVC: UIViewController, SkyViewDelegate {
    @IBOutlet weak var skyView: SkyView!

    @IBOutlet weak var unlockButton: UIButton!  // no longer used

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.skyViewVC = self
            skyView.setGestures(appDelegate: appDelegate)
            skyView.settings = appDelegate.settings
            skyView.annotations = appDelegate.annotations
            skyView.delegate = self
        }
        unlockButton.alpha = 0.0
    }
    
    /*
     Match the center point of the Aladin view
     The view here "tracks" where the phone is pointed when 'tracking' is true
     and the bullseye is shown.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // see AladinVC.viewWillDisappear()
        // Think about before changing:  user jumps from Aladin to Settings, then to SkyView
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let vc = appDelegate.aladinVC {
            vc.aladin?.getRaDec(completionHandler: {
                ra,dec,error in
                if error == nil {
                    self.skyView.aladinPlus = (ra:ra,dec:dec)
                }
            })
            vc.aladin?.getFovCorners(completionHandler: {
                vals,error in
                if error == nil {
                    if let corners = vals as? [(ra:Double,dec:Double)] {
                        self.skyView.setAladinCorners(corners)
                    }
                }
            })
            self.skyView.setNeedsDisplay()
        }
    }
    
    // MARK: SkyViewDelegate
    func didTapSkyView() {
    }
    
    func didPanSkyView() {
    }

    //hack
//    func makeConstellationLines() {
//        let constellations = Constellations()
//        for name in ["scl"] {
//            if let points = constellations.getConstellationPointsXYZ0(name) {
//                for point in points {
//                    print("\(point.first.x)\t\(point.first.y)\t\(point.first.z)\t\(point.second.x)\t\(point.second.y)\t\(point.second.z))")
//                }
//            }
//        }
//    }
}
