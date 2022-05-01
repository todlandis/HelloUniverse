//
//  Convert.swift
//  Copyright © 2020,2021,2022 Tod Landis. All rights reserved.
//
// horizons,NGCPlot
// 5.0

import Foundation

class Convert {
    
    class func arcsecToDegrees(_ arcsec:Double) -> Double {
        return arcsec / 3600.0
    }
    
    // e.g. "icrs 13 42 11.62 +28 22 38.2"
    class func icrsToRADec(string:String) -> (ra:Double, dec:Double)? {
        return icrsToRADec(string.components(separatedBy: .whitespaces))
    }
    
    class func raDecToIcrs(ra:Double, dec:Double, underscored:Bool = false) -> String {
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
    
    class func hmsToDecimalHours(h:Double,m:Double,s:Double) -> Double {
        if(h < 0.0) {
            return h - m/60.0 - s/3600.0
        }
        else {
            return h + m/60.0 + s/3600.0
        }
    }
    
    class func decimalHoursToHMS(_ hours:Double) -> (h:Double,m:Double,s:Double){
        let negative = hours < 0
        let hoursDecimal = abs(hours)
        
        var h = floor(hoursDecimal)
        let m = floor((hoursDecimal - h) * 60.0 )
        let s = ((hoursDecimal - h) * 3600) - (m * 60.0)
        if negative {
            h = -h
        }
        return (h,m,s)
    }
    
    class func decimalDegreesToDecimalHours(_ val:Double) -> Double {
        return val / 15.0
    }
    
    class func decimalHoursToDegrees(_ val:Double) -> Double {
        return val * 15.0
    }
    
    class func hmsToDecimalHours(_ s:String,separator:String = " ") -> Double {
        let (h,m,s) = Convert.stringToThreeValues(s,separator: separator)
        if h < 0 {
            return h - m/60.0 - s/3600.0
        }
        else {
            return h + m/60.0 + s/3600.0
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
    
    
    // "23 24 48.0"
    class func stringToThreeValues(_ s:String,separator:String=" ") -> (h:Double,m:Double,s:Double){
        let fields = s.trimmingCharacters(in: .whitespaces).replacingOccurrences(of:"  ", with:" ").components(separatedBy: separator)

        var h = 0.0
        var m = 0.0
        var s = 0.0
        if fields.count > 0 {
            if let hh = Double(fields[0]) {
                h = hh
            }
        }
        if fields.count > 1 {
            if let mm = Double(fields[1]) {
                m = mm
            }
        }
        if fields.count > 2 {
            if let ss = Double(fields[2]) {
                s = ss
            }
        }
        return (h,m,s)
    }
    
    // "23 24 48.0"
    class func hmsToDecimalDegrees(_ hmsString:String,separator:String = " ") -> Double? {
        let (h,m,s) = stringToThreeValues(hmsString,separator:separator)
        let val = hmsToDecimalHours(h: h, m: m, s: s)
        return  val * 15.0
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
    class func dmsToDecimalDegrees(_ dmsString:String,separator:String = " ") -> Double? {
        var fields = dmsString.trimmingCharacters(in: .whitespaces).replacingOccurrences(of:"  ", with:" ").replacingOccurrences(of: "−", with: "-").components(separatedBy: separator)

        var d = 0.0
        var m = 0.0
        var s = 0.0
        if fields.count > 0 {
            if fields[0] == "−00" {
                fields[0] = "0"
            }
            if let dd = Double(fields[0]) {
                d = dd
            }
        }
        if fields.count > 1 {
            if let mm = Double(fields[1]) {
                m = mm
            }
        }
        if fields.count > 2 {
            if let ss = Double(fields[2]) {
                s = ss
            }
        }
        if(d < 0) {
            return (d - m/60.0 - s/3600.0)
        }
        else {
            return (d + m/60.0 + s/3600.0)
        }
    }
    
    class func dmsToDecimalDegrees(d:Double, m:Double, s:Double) -> Double {
        if(d < 0) {
            return (d - m/60.0 - s/3600.0)
        }
        else {
            return (d + m/60.0 + s/3600.0)
        }
    }
    
    // p. 15
    class func test() {
        if let degrees = Convert.dmsToDecimalDegrees("23 24 48.0") {
            let (h,m,s) = Convert.decimalDegreesToDMS(degrees)
            print("\(h) \(m) \(s)")
        }
    }
    class func test1() {
        print(Convert.decimalHoursToHMS(18.524167))
        // (h: 18.0, m: 31.0, s: 27.001199999994697) matches the books
    }
    class func test2() {
        if let degrees = Convert.hmsToDecimalDegrees("23 24 48.0") {
            print("degrees = \(degrees)")
            let (h,m,s) = Convert.decimalDegreesToHMS(degrees)
            print("\(h) \(m) \(s)")
        }
    }
}
