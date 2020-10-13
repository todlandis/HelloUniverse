//
//  Astro.swift
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
import simd
import Accelerate


class Astro {
    
    // map (ra,dec) -> (alt,az) for a given time and location
    // http://star-www.st-and.ac.uk/~fv/webnotes/chapter7.htm
    class func altAz(ra:Double, dec:Double, date:Date, lat:Double, lon:Double) -> (alt:Double,az:Double) {
        
        var H = localMeanSiderealTime(date: date, longitude: lon) - ra
        
        if H < 0.0 {
            H = H + 360.0
        }
        if H > 360.0 {
            H = H - 360.0
        }
        let decR = dec * Double.pi/180.0
        let latR = lat * Double.pi/180.0
        let HR =     H * Double.pi/180.0

        let alt = asin(sin(decR) * sin(latR) + cos(decR) * cos(latR) * cos(HR))
        var az = acos( (sin(decR) - (sin(alt) * sin(latR))           ) / (cos(alt) * cos(latR)) )
        if(sin(HR) > 0) {
            az = (2.0 * Double.pi) - az
        }
        return (alt * 180.0/Double.pi,az * 180.0/Double.pi)
    }
    
    // returns LMST in degrees
    class func localMeanSiderealTime(date:Date, longitude:Double) -> Double {
        var l = greenwichMeanSiderealTime(date:date) + longitude
        if l < 0.0 {
            l = l + 360.0
        }
        if l > 360.0 {
            l = l - 360.0
        }
        return l
    }
    
    // returns GMST in degrees
    class func greenwichMeanSiderealTime(date:Date) -> Double {
        return 360.0 * greenwichMeanSiderealTimeS(date:date)/86400.0
    }
    
    /*
     returns GMST in sidereal seconds for 'date' in Greenwich Time
     The returned value will be in the range 0 - 86400.
     */
    class func greenwichMeanSiderealTimeS(date:Date) -> Double {
        //        https://astronomy.stackexchange.com/questions/21002/how-to-find-greenwich-mean-sideral-time
        //         https://www.cfa.harvard.edu/~jzhao/times.html#GMST
        let midnight = calcMidnight(date)!
        let JD = dateToJulianDate(midnight)
        
        let d = Double(JD) - 2451545.0      // Julian days
        let T = d / 36525.0         // Julian centuries from 2000 Jan. 1 12h UT1
        
        // Greenwich sidereal time at midnight in seconds
        // eqn (2) from the stackexchange post
        let H0 = 24110.54841 + 8640184.812866 * T
            + 0.093104 * T * T - 0.0000062 * T * T * T
        
        // This is eqn (4) from the stackexchange post
        // omega is the Earth's rotation rate in radians/second
        let omega = 1.00273790935 + 5.9E-11
        
        var GMST =  H0 + omega  * timeSinceMidnight(date)
        GMST = GMST.remainder(dividingBy: 86400.0)
        if GMST < 0.0 {
            GMST = GMST + 86400.0
        }
        return GMST
    }
    
    // returns 'dateIn' as a Julian date.
    // follows this description:  https://www.aavso.org/computing-jd
    class func dateToJulianDate(_ dateIn:Date) -> Double {
        //print(dateIn)
        
        // reference Julian Date for noon on 1/1/2010
        // from https://www.aavso.org/computing-jd
        let JULIAN_DATE_JAN_1_2010 = 2455198
        
        // count number of Noons between this date and Noon on 1/1/2010
        let noon2010 = makeNoon(year:2010)
        let between = dateIn.timeIntervalSince(noon2010)
        var days = Int(between/(24 * 60 * 60))

        // if dateIn was before noon2010 there will be an extra day counted
        if between < 0 {
            days -= 1
        }
        
        let JDN = JULIAN_DATE_JAN_1_2010 + days
        
        // substract 12 hours in order to calculate the fraction of a day
        // since the previous Noon
        let date = dateIn.addingTimeInterval(-12.0 * 60.0 * 60.0)
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let val = calendar.dateComponents([.year, .month, .day,.hour,.minute,.second], from: date)
        
        let fraction:Double = (Double(val.hour!) + Double(val.minute!)/60.0 + Double(val.second!)/3600.0)/24.0
        
        return Double(JDN) + fraction
    }

    // returns (ra,dec) for a point directly overhead
    class func zenith(date:Date, latitude:Double, longitude:Double) -> (ra:Double,dec:Double) {
        return (ra:localMeanSiderealTime(date: date, longitude: longitude), dec:latitude)
    }
    
    class func test() {
        let lat = 38.0
        let lon = -122.0
        let now = Date()
        for j in 0...36 {
            print()
            let ra = Double(j) * 10.0
            for i in 0...18 {
                let dec = Double(i) * 10.0 - 90.0
                //  print(dec)
                let (alt,az) = altAz(ra: ra,dec: dec, date:now, lat: lat, lon:lon)
                let (ra2,dec2) = raDec(altitude: alt, azimuth: az, date: now, lat: lat, lon: lon)
                if (fabs(ra2 - ra) > 10e-10 &&  fabs(ra2 - ra) < 359.9) || fabs(dec2 - dec) > 10e-10 {
                    print("\(ra),\(dec)    ra diff:\(fabs(ra-ra2)),  dec diff:\(fabs(dec-dec2))")
                }
                else {
                    print("\(ra),\(dec) ")
                }
            }
        }
    }
    
    // 140.0,50.0    ra diff:139.38729137250544,  dec diff:0.0
    class func testX() {
        let lat = 38.0
        let lon = -122.0
        let ra = 140.0
        let dec = 50.0
        let now = Date()
        print((ra,dec))
        let (alt,az) = altAz(ra: ra,dec: dec, date:now, lat: lat, lon:lon)
        let (ra2,dec2) = raDec(altitude: alt, azimuth: az, date: now, lat: lat, lon: lon)
        print((ra2,dec2))
    }
    
    class func test5() {
        // values from http://www.stargazing.net/kepler/altaz.html
        
        let now = makeDate("1998-08-10 23:10:00 +0000")!
        let lat = 52.5
        let lon = -1.9166667
        let ra = 250.425
        let dec = 36.466667
        
        print((ra,dec))
        let (alt,az) = altAz(ra: ra,dec: dec,date: now,lat:lat,lon:lon)
        print((alt,az))
// calculated here
//        (49.168868703951716, 269.1466694831747)
// matches web site
//        49.169122 degs = 49 d + 0.169122 * 60 min =  49 d 10 min
//        269.14634 degs = 269 d + 0.14634 * 60 min = 269 d  9 min

        let (ra2,dec2) = raDec(altitude: alt, azimuth: az, date: now, lat: lat, lon: lon)
        print((ra2,dec2))

    }
    
    // still work in progress
    class func raDec(altitude:Double, azimuth:Double, date:Date, lat:Double, lon:Double) -> (ra:Double,dec:Double) {
        
        return (ra:0,dec:0)
    }
    
    // map (ra,dec) to (x,y,z) on the unit sphere
    //
    // (0,0) -> (1,0,0)
    // (ra,0) -> a circle in the xy-plane as ra varies from 0 to 360
    // e.g. (90,0) -> (0,1,0)
    //
    // (0,dec) -> a circle in the xz-plane as dec varies from 0 to 360
    // e.g. (0,90) -> (0,0,1)
    // dec is expected in the range -90 to 90
    //
    class func raDecToXYZ(ra:Double,dec:Double) -> simd_double3? {
        let raRadians = ra * Double.pi/180.0
        let decRadians = dec * Double.pi/180.0
        return simd_double3(cos(raRadians) * cos(decRadians),
        sin(raRadians) * cos(decRadians),
        sin(decRadians))
    }

    // map (x,y,z) on the unit sphere to (ra,dec)
    class func xyzToRaDec(x:Double, y:Double, z:Double) -> (ra:Double, dec:Double) {
        var ra =  atan2(y, x) * 180.0/Double.pi
        if(ra < 0.0) {
            ra = ra + 360.0
        }
        let dec = asin(z)     *  180.0/Double.pi
        return (ra,dec)
    }
    
    
    // Returns midnight on 'date'.  12:00 AM = 00:00:00
    class func calcMidnight(_ date:Date) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = calendar.dateComponents([.year,.month,.day], from:date)
        let newComponents = DateComponents(year: components.year, month:components.month, day: components.day, hour: 00, minute: 0, second: 0)
        return calendar.date(from: newComponents)!
    }
    
    // time since midnight in seconds
    class func timeSinceMidnight(_ date:Date) -> Double {
        let midnight = calcMidnight(date)!
        return date.timeIntervalSince(midnight)
    }
        
    
    // retuns a Date for noon on Jan 1 in 'year'
    class func makeNoon(year:Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month:1, day: 1, hour: 12, minute: 0, second: 0)
        return calendar.date(from: components)!
    }
    
    // retuns a Date corresponding to "yyyy-MM-dd HH:mm:ss zzzz"
    class func makeDate(_ s:String) -> Date? {
        let formatter = DateFormatter()
        //        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzzz"
        let ret = formatter.date(from: s)
//        print(ret!)
        return ret
    }
    

    class func testu() {
        // values from http://www.stargazing.net/kepler/altaz.html
        
        let now = makeDate("1998-08-10 23:10:00 +0000")!
        let lat = 52.5
        let lon = -1.9166667
        let ra = 250.425
        let dec = 36.466667
        
        print((ra,dec))
        let (alt,az) = altAz(ra: ra,dec: dec,date: now,lat:lat,lon:lon)
        print((alt,az))
// calculated here
//        (49.168868703951716, 269.1466694831747)
// matches web site
//        49.169122 degs = 49 d + 0.169122 * 60 min =  49 d 10 min
//        269.14634 degs = 269 d + 0.14634 * 60 min = 269 d  9 min

        let (ra2,dec2) = raDec(altitude: alt, azimuth: az, date: now, lat: lat, lon: lon)
        print((ra2,dec2))

    }

}
