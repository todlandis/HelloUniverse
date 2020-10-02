//
//  Telescope.swift
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

import Foundation

/*
       c8 has focal length 2032 mm

 https://www.celestron.com/products/125in-eyepiece-and-filter-kit
 32 mm Plossl Eyepiece - 1.25”
 17 mm Plossl Eyepiece - 1.25”
 13 mm Plossl Eyepiece - 1.25”
 8 mm Plossl Eyepiece - 1.25”
 6 mm Plossl Eyepiece - 1.25”
 2X Barlow Lens - 1.25”
 #80A Blue Filter - 1.25”
 #58 Green Filter - 1.25”
 #56 Light Green Filter - 1.25”
 #25 Red Filter - 1.25”
 #21 Orange Filter - 1.25”
 #12 Yellow Filter - 1.25”
 Moon Filter - 1.25”
   52º apparent field of view.
   true field = apparent field/magnification

 magnification = scope/eyepiece = 2032/32

 */
class Telescope {
    let focalLength = 2032.0    // 2032 mm for the C8
    let apparentFOV = 52.0      // 52 degrees for C8
    
    var eyepiece:Double = 32.0
    var trueFOV:Double =  52.0 / (2032.0/32.0)        // for the current eyepiece
    var magnification:Double = 2032.0 / 32.0    // for the current eyepiece
    
    // possible eyepieces in a standard set, the 2X barlow doubles the magnification
    let eyepieces:[Double] = [32.0, 17.0, 13.0, 8.0, 6.0]
    
    static let shared: Telescope = {
        let instance = Telescope()
        return instance
    }()

    func setEyepieceAperture(_ aperture:Double) {
        eyepiece = aperture
        magnification = calcMagnification(eyepiece)
        trueFOV = calcTrueFOV(eyepiece)
    }
    
    // calculate the magnification for this 'focalLength' and an eyepiece with 'aperture'
    func calcMagnification(_ aperture:Double) -> Double {
        return focalLength / aperture
    }
    
    func calcTrueFOV(_ aperture:Double) -> Double {
        return apparentFOV/calcMagnification(aperture)
    }
    
}
