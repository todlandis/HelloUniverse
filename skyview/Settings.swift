//
//  Settings.swift
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

class Settings {
    var drawConstellationLines = true
    var drawConstellationNames = true
    var drawGrid =     false
    var drawFOV =      false         
    var drawBayer =    false
    var drawCommonNames =  false
    var drawMagnitude =    false       // ui does not surface this yet
    var drawMessier =      true

    var drawBullsEye =     false       // ui does not surface this yet
    var drawAladin =       false
    var drawPlusSigns =    true
    
    var messierLabelSize =       CGFloat(14.0)
    var constellationLabelSize = CGFloat(18.0)
    var starNameLabelSize =      CGFloat(18.0)
    
    var starColor =     UIColor.white

    var messierColor = TangoColors.TANGOORANGE
    
    var survey = "P/DSS2/color"
}
