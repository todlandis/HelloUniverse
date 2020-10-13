//
//  Convert.swift
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
// 2.0

import Foundation

class Convert {
    
    class func arcsecToDegrees(_ arcsec:Double) -> Double {
        return arcsec / 3600.0
    }
    
    // e.g. "icrs 13 42 11.62 +28 22 38.2"
    class func icrsToRADec(string:String) -> (ra:Double, dec:Double)? {
        return icrsToRADec(string.components(separatedBy: .whitespaces))
    }
    
    class func raDecToIcrs(ra:Double, dec:Double, underscored:Bool = true) -> String {
        let (h,m,s) = Convert.decimalDegreesToHMS(ra)
      //  print("\(ra) -> \(h) \(m) \(s)")
        let (dd,mm,ss) = Convert.decimalDegreesToDMS(dec)
      //  print("\(dec) -> \(dd) \(mm) \(ss)")
        var sign = ""
        var id = 0
        if(dd > 0) {
            sign = "+"
            id = Int(dd)
        }
        else {
            sign = "-"
            id = Int(-dd)
        }
        
        if underscored {
            // blanks are replaced with underscores
            return String(format:"%02d_%02d_%.3f_\(sign)%02d_%02d_%.3f",Int(h),Int(m),s,id,Int(mm),ss)
        }
        else {
            return String(format:"%02d %02d %.3f \(sign)%02d %02d %.3f",Int(h),Int(m),s,id,Int(mm),ss)
        }
    }
    
    class func icrsToRADec(_ components:[String]) -> (ra:Double, dec:Double)? {
        if(components[0] != "icrs") {
            print("ERROR in icrsToRADec() - first component must be \"icrs\"")
            return nil
        }
        
        var ra = 0.0
        var dec = 0.0
        if let h = Double(components[1]),
            let m = Double(components[2]),
            let s = Double(components[3]) {
            let val = (h + m/60.0 + s/3600.0)  // decimal hours
            ra =  val * 15.0                 //  360.0/24.0
        }
        else {
            return nil
        }
        
        if let d = Double(components[4]),
            let m = Double(components[5]),
            let s = Double(components[6]) {
            if(d < 0) {
                dec = (d - m/60.0 - s/3600.0)
            } else {
                dec = (d + m/60.0 + s/3600.0)
            }
        }
        else {
            return nil
        }
        return (ra,dec)
    }
    
    class func test2() {  // not working!
        if let degrees = Convert.hmsToDecimalDegrees("23 24 48.0") {
            print("degrees = \(degrees)")
            let (h,m,s) = Convert.decimalDegreesToHMS(degrees)
            print("\(h) \(m) \(s)")
        }
    }
    
    class func test() {
        if let degrees = Convert.dmsToDecimalDegrees("23 24 48.0") {
            let (h,m,s) = Convert.decimalDegreesToDMS(degrees)
            print("\(h) \(m) \(s)")
        }
    }

    class func decimalDegreesToHMS(_ valIn:Double) -> (h:Double, m:Double, s:Double) {
        let val = valIn / 15.0
        let h = floor(val)
        let frac = (val - h)
        let m = floor(frac * 60)
        let s = (frac * 3600) - (m * 60)
        return (h,m,s)
    }
    
    
    
    //23 24 48.0
    class func hmsToDecimalDegrees(_ s:String) -> Double? {
        let fields = s.trimmingCharacters(in: .whitespaces).replacingOccurrences(of:"  ", with:" ").replacingOccurrences(of: "−", with: "-").components(separatedBy: " ")
        if fields.count < 3 {
            return nil
        }

        if let h = Double(fields[0]),
        let m = Double(fields[1]),
            let s = Double(fields[2]) {
            let val = (h + m/60.0 + s/3600.0)  // decimal hours
            return  val * 15.0                 //  360.0/24.0
        }
        else {
            return nil
        }
    }
    
    class func decimalDegreesToDMS(_ valIn:Double) -> (d:Double,m:Double,s:Double) {
        var negative = false
        var val = valIn
        if(val < 0) {
            negative = true
            val = -val
        }
        var d = floor(val)
        let frac = (val - d)
        let m = floor(frac * 60)
        let s = (frac * 3600) - (m * 60)
        if(negative) {
            d = -d
        }
        return (d,m,s)
    }

    //  +61 35 36
    class func dmsToDecimalDegrees(_ s:String) -> Double? {
        var fields = s.trimmingCharacters(in: .whitespaces).replacingOccurrences(of:"  ", with:" ").replacingOccurrences(of: "−", with: "-").components(separatedBy: " ")
        if fields.count < 3 {
            return nil
        }
        if fields[0] == "−00" {
            fields[0] = "0"
        }

        if let d = Double(fields[0]),
            let m = Double(fields[1]),
            let s = Double(fields[2]) {
            if(d < 0) {
                return (d - m/60.0 - s/3600.0)
            } else {
                return (d + m/60.0 + s/3600.0)
            }
        }
        else {
            return nil
        }
    }
}
