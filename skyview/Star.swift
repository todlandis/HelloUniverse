//
//  Star.swift
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

class Star {
   var hr:Int = 0
    var name:String = ""         // original name, not used
    var ra:Double = 0
    var dec:Double = 0
    var magnitude:Double = 0
    // good description of type here:  https://en.wikipedia.org/wiki/Stellar_classification
    var spectralType:String = ""
    var commonName:String = ""
    var num:String = ""           // from name
    var greek:String = ""         // "
    var constellation = ""        // "
    var spec = ""
    var lumin = ""
    var parsecs = ""
    var ly = ""
    var xs = 0.0       // x,y,z on the unit sphere by mapping ra,dec
    var ys = 0.0
    var zs = 0.0
}
