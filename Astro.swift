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
// 2.0

import UIKit
import CoreMotion
import simd
import Accelerate

class Astro {
    
    enum WhichWay {
    case backCamera
    case topOfPhone
    }
    
    static var pointingDirection:WhichWay = .topOfPhone
    // not working yet
    // calculate ra/dec for a given alt,az, time, lat and lon
    // http://star-www.st-and.ac.uk/~fv/webnotes/chapter7.htm
    // in the link the "cosine rule" refers to the cosine rule from spherical trig:
    // https://en.wikipedia.org/wiki/Spherical_law_of_cosines
    // the "sine rule" is here:
    // https://en.wikipedia.org/wiki/Law_of_sines#Spherical_case
    class func raDecOLD(alt:Double, azimuth:Double, date:Date, lat:Double, lon:Double) -> (ra:Double,dec:Double) {
        
        let altR = alt * Double.pi/180.0
        let azimuthR = azimuth * Double.pi/180.0
        let latR = lat *  Double.pi/180.0

        // sin(δ) = sin(a)sin(φ) + cos(a) cos(φ) cos(A)
    //    print("sin(altR) = \(sin(altR))")
//        let sum = sin(altR) * sin(latR) + cos(altR) * cos(latR) * cos(azimuthR)
//
//        print()
//        print("sum = \(sum)")

        let dec = asin(sin(altR) * sin(latR) + cos(altR) * cos(latR) * cos(azimuthR))
      //  print("dec = \(dec)")
        
        // sin(H) = - sin(A) cos(a) / cos(δ)
        let H = asin(-sin(azimuthR) * cos(altR) / cos(dec))
        //print("H = \(H)")
        
        // α = t – H/
        var ra =  localMeanSiderealTime(date: date, longitude: lon) - (H * 180.0/Double.pi)

        if(ra < 0) {
            print("ra is less than 0")
            ra = ra + 360.0
        }
        if(ra > 360) {
            print("ra is greater than 360")
            ra = ra - 360.0
        }

        return (ra,dec * 180.0/Double.pi)
    }
    
    // map (ra,dec) to (x,y,z) on the unit sphere
    //
    // (0,0) -> (1,0,0)
    // (ra,0) -> a circle in the xy-plane as ra varies from 0 to 360
    // e.g. (90,0) -> (0,1,0)
    //
    // (0,dec) -> a circle in the xz-plane as dec varies from 0 to 360
    // e.g. (0,90) -> (0,0,1)
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
    
    class func raDec(alt:Double, azimuth:Double, date:Date, lat:Double, lon:Double) -> (ra:Double,dec:Double) {
        
        // first do lat = 0, this will avoid the problem in testRaDec7 before replacing
        //   raDecOLD with this
        var (ra,dec) = raDecOLD(alt: alt, azimuth: azimuth, date: date, lat:lat, lon:lon)
 //       print("old way \(ra)  \(dec)")

        // with this longitude and replacing the lat with lat=0 where is alt,azimuth pointing?
        (ra,dec) = raDecOLD(alt: alt, azimuth: azimuth, date: date, lat:0, lon:lon)

        // map (ra,dec) to a point on the unit sphere
        let p = Astro.raDecToXYZ(ra: ra, dec: dec)
        let p2 = Matrix.rotationAroundY(degrees: -lat) * p!

        (ra,dec) = Astro.xyzToRaDec(x:p2.x, y:p2.y, z:p2.z)
//        print("new way \(ra)  \(dec)")
        return (ra,dec)
    }

    // map (alt,az) at lat:0,lon:0 to (ra,dec)
    class func raDecForZeroZero(alt:Double, azimuth:Double, date:Date) -> (ra:Double,dec:Double) {
        let lat = 0.0
        let lon = 0.0
        
        let altR = alt * Double.pi/180.0
        let azimuthR = azimuth * Double.pi/180.0
        let latR = lat *  Double.pi/180.0

        // sin(δ) = sin(a)sin(φ) + cos(a) cos(φ) cos(A)
   //     print("sin(altR) = \(sin(altR))")
//        let sum = sin(altR) * sin(latR) + cos(altR) * cos(latR) * cos(azimuthR)

//        print()
//        print("sum = \(sum)")
        
        let dec = asin(sin(altR) * sin(latR) + cos(altR) * cos(latR) * cos(azimuthR))
     //   print("dec = \(dec)")
        
        // sin(H) = - sin(A) cos(a) / cos(δ)
        let H = asin(-sin(azimuthR) * cos(altR) / cos(dec))
        //print("H = \(H)")
        
        // α = t – H/
        var ra =  localMeanSiderealTime(date: date, longitude: lon) - (H * 180.0/Double.pi)

        if(ra < 0) {
            print("ra is less than 0")
            ra = ra + 360.0
        }
        if(ra > 360) {
            print("ra is greater than 360")
            ra = ra - 360.0
        }

        return (ra,dec * 180.0/Double.pi)
    }
  
//    class func testAltAz() {
//        let now = Date()
//        let lat = 37.0
//        let lon = -122.0
//        let ra = 0.0
//        for dec in [85,87.5,90,92.5,95] {
//            let (alt,az) = altAz(ra: ra,dec: dec,date: now,lat: lat,lon: lon)
//            print("(\(ra),\(dec) -> (\(alt),\(az))")
//        }
//    }
    

    // calculate alt(degrees) and az(degrees) for a given time, location, ra (degrees), and dec (degrees)
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
    
    /*
     calculate Alt-Azimuth for the pointDirection in the current phone attitude
     this helps understand getting the angle between a line and a plane:
     https://www.superprof.co.uk/resources/academic/maths/analytical-geometry/distance/angle-between-line-and-plane.html
     */
    class func calcAltAzimuth(motion:CMDeviceMotion) -> (alt:Double,az:Double) {
        // get the attitude of the phone as a quaternion
        let qMotion = motion.attitude.quaternion
        let q = simd_quatd(ix:qMotion.x,iy:qMotion.y,iz:qMotion.z,r:qMotion.w)
        
        // rotate a vector pointing in 'pointDirection' to match the phone attitude
        let vecBack = simd_act(q, simd_double3(0.0,0.0,-1.0))

        var vec:simd_double3
        switch(Astro.pointingDirection) {
        case .backCamera:
            vec = vecBack
        case .topOfPhone:
            vec = simd_act(q, simd_double3(0.0,1.0,0.0))
        }

        
        // altitude = the angle of pointDirection with the xy plane
        // take the plane normal, (0,0,1),
        // dot vec normalized to get
        // the cosine of the angle it makes with the normal.  Take the
        // complement of that angle to get the angle it makes witzh the plane.
        // and use     cos(90 - angle) = sin(angle)
        let alt = asin(vec.z/simd_length(vec)) * 180.0/Double.pi
        var az =  motion.heading

        let dotProduct = simd_dot(vecBack, simd_double3(0.0,0.0,1.0))
      //  print("dot with z = \(dotProduct)")
        if dotProduct > 0 {
            // the screen is facing toward the ground
            az = az + 180
            if az > 360 {
                az = az - 360
            }
        }
//print()
//print("az from motion.heading:  \(az)")
        // OLD - this doesn't work,
// see 18:45 in Create Immersive Apps With Core Motion,2017
        // azimuth = the angle with the yz plane
        // take the plane normal, (1,0,0), dot vec normalized to get
        // the cosine of the angle it makes with the normal.
        
        // cos (90° + θ) = - sin θ
//        var az2 =  Double(-asin(vec.x/simd_length(vec))) * 180.0/Double.pi
//        print("az from calculation:  \(az2)")
//        print()

        return (alt,az)
    }
    
//    class func testCalculateJD() {
//        print("sb 2458484.5:  ",terminator:"")
//        var d = makeDate("2019-01-01 00:00:00 +0000")
//        print(dateToJulianDate(d!))
//        // got 2458484.5
//
//        print("sb 2455196.70833  ",terminator:"")
//        d = makeDate("2009-12-31 05:00:00 +0000")
//        print(dateToJulianDate(d!))
//        // got 2455196.7083333335
//
//        print("sb 2451666.93334:  ",terminator:"")
//        d = makeDate("2000-05-02 10:24:01 +0000")
//        print(dateToJulianDate(d!))
//        // got 2451667.9333449076
//        
//        print("sb 2470171.99932  ",terminator:"")
//        d = makeDate("2050-12-31 11:59:01 +0000")
//        print(dateToJulianDate(d!))
//        // got 2470171.9993171296
//        
//        print("sb 2459580.29098  ",terminator:"")
//        d = makeDate("2021-12-31 18:59:01 +0000")
//        print(dateToJulianDate(d!))
//        // got 459580.290983796
//        
//        print("sb 2459257.18434  ",terminator:"")
//        d = makeDate("2021-02-11 16:25:27 +0000")
//        print(dateToJulianDate(d!))
//        // got 2459257.1843402777
//    }
//    
//    class func testGMST() {
//        var gmst:Double
//        
//        // reference value on link is 52965.37916293584
//        // sb                         52965.3791643118
//        gmst = greenwichMeanSiderealTimeS(date:makeDate("2019-01-01 08:00:00 +0000")!)
//        print(gmst)
//        // got 52965.3791643118
//        
//        var degrees = 360.0 * gmst/86400
//        print(Convert.decimalDegreesToHMS(degrees))
//        // (h: 14.0, m: 42.0, s: 45.37916431180838)
//        
//        gmst = greenwichMeanSiderealTimeS(date:makeDate("2020-08-05 16:30:41 +0000")!)
//        print(gmst)
//        degrees = 360.0 * gmst/86400
//        print(Convert.decimalDegreesToHMS(degrees))
//        // matched 13h 29m 25.496s = 13.4904156053 h in an online calculator
//
//        gmst = greenwichMeanSiderealTimeS(date:makeDate("2020-08-07 05:00:00 +0000")!)
//        print(gmst)
//        degrees = 360.0 * gmst/86400
//        print(Convert.decimalDegreesToHMS(degrees))
//        
//// got (h: 2.0, m: 4.0, s: 44.145190841984004)
//// which matches http://phpsciencelabs.us/wiki_programs/Sidereal_Time_Calculator.php
//// 02h 04m 44.145s = 2.0789292249 h
//        
//    }
//    
//    class func testLMST() {
//        var degrees = localMeanSiderealTime(date:Date(), longitude: -122.1395858334356)
//        print("LMST =  \(Convert.decimalDegreesToHMS(degrees))")
//        // results matched https://sidereal.app/Calculate to within
//        // a few seconds
//        
//        print("lon = \(Convert.decimalDegreesToDMS(-122.25))")
//        degrees = localMeanSiderealTime(date:makeDate("2020-08-05 16:30:41 +0000")!, longitude: -122.225)
//        print("LMST =  \(Convert.decimalDegreesToHMS(degrees))")
//        
//        degrees = localMeanSiderealTime(date:makeDate("2020-08-07 05:00:00 +0000")!, longitude: -122.225)
//        print("LMST =  \(Convert.decimalDegreesToHMS(degrees))")
//    }
//
//    // want to understand what is happening near the north pole
//    //  facing north, I raise the phone through my latitude (~37)
//    //  the center point of the sky map approaches the north pole, but
//    //  as I increase the inclination of the phone it comes back down to
//    //  about the same point in Draco where I started
//    class func testRaDec4() {
//        let az = 0.0
//        let alt = 37.0
//        let date = Date()
//        let lat = 37.0
//        let lon = -122.0
//        let (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("ra = \(ra)  dec = \(dec)")
//        //ra = 330.46032077811543  dec = 90.0
//    }
//    
//    class func testRaDec7() {
//        let date = Date()
//        let lat = 37.0
//        let lon = -122.0
//
//        let az = 0.0
//        var alt = 30.0
//        var (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print()
//        print("(alt:\(alt),az:\(az)) -> (ra:\(ra),  dec:\(dec))")
//
//        alt = 37.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("(alt:\(alt),az:\(az)) -> (ra:\(ra),  dec:\(dec))")
//
//        alt = 44.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("(alt:\(alt),az:\(az)) -> (ra:\(ra),  dec:\(dec))")
//    }
//    
//    class func testRaDec5() {
//        let az = 0.0
//        let date = Date()
//        let lat = 37.0
//        let lon = -122.0
//
//        var alt = 30.0
//        var (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for 30:  ra = \(ra)  dec = \(dec)")
//        
//        var (alt2,az2) =  Astro.altAz(ra: ra, dec: dec, date: date, lat: lat, lon: lon)
//        print("alt2 = \(alt2)")
//        print("alt2 = \(alt2) az2 = \(az2)")
//
//        alt = 34.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for 34:  ra = \(ra)  dec = \(dec)")
//
//        alt = 37.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for 37  ra = \(ra)  dec = \(dec)")
//
//        alt = 40.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for 40  ra = \(ra)  dec = \(dec)")
//        
//        alt = 44.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for alt = 44  ra = \(ra)  dec = \(dec)")
//        (alt2,az2) =  Astro.altAz(ra: ra, dec: dec, date: date, lat: lat, lon: lon)
//        print("alt2 = \(alt2) az2 = \(az2)")
//    }
//
//    class func testRaDec6() {
//        let az = 0.0
//        var alt = 36.0
//        let date = Date()
//        let lat = 37.0
//        let lon = -122.0
//        var (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for 36:  ra = \(ra)  dec = \(dec)")
//
//        alt = 37.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for 37  ra = \(ra)  dec = \(dec)")
//
//        alt = 38.0
//        (ra,dec) = Astro.raDec(alt: alt, azimuth: az, date: date, lat: lat, lon: lon)
//        print("for 38  ra = \(ra)  dec = \(dec)")
//        
////        for 36:  ra = 332.5467741718923  dec = 89.0000000000001
////        for 37  ra = 332.5467741718923  dec = 90.0
////        for 38  ra = 332.5467741718923  dec = 88.99999999999976
//
//    }
//
//    // a round trip...
//    class func testRaDec() {
//        // Dubhe values from SkySafari
//        let ra =  Convert.hmsToDecimalDegrees("11 04 58.22")
//        let dec = Convert.dmsToDecimalDegrees("61 38 29.3")
//        
//        // Santa Cruz
//        let lat = Convert.dmsToDecimalDegrees("36 58 26.8")
//        let lon = Convert.dmsToDecimalDegrees("-122 01 50.9")
//        
//        let date = makeDate("2020-08-05 16:30:41 +0000")
//        
//        let (alt,az) = Astro.altAz(ra:ra!, dec:dec!, date:date!, lat:lat!, lon:lon!)
//        let (ra2,dec2) = Astro.raDec(alt: alt, azimuth: az, date: date!, lat: lat!, lon: lon!)
//        
//        print("ra = \(Convert.decimalDegreesToHMS(ra2))")
//        print("dec = \(Convert.decimalDegreesToDMS(dec2))")  // good!
//    }
//    
//    class func testAltAz2() {
//        // Dubhe values from SkySafari
//        let ra =  Convert.hmsToDecimalDegrees("11 04 58.22")
//        let dec = Convert.dmsToDecimalDegrees("61 38 29.3")
//        
//        // Santa Cruz
//        let lat = Convert.dmsToDecimalDegrees("36 58 26.8")
//        let lon = Convert.dmsToDecimalDegrees("-122 01 50.9")
//        
//        let date = makeDate("2020-08-05 16:30:41 +0000")
//        
//        let (alt,az) = Astro.altAz(ra:ra!, dec:dec!, date:date!, lat:lat!, lon:lon!)
//
//        print()
//        print()
//        print(alt, terminator:"")
//        print("  (want \(Convert.dmsToDecimalDegrees("33 49 27.5")!))")
//        print(az, terminator:"")
//        print("  (want \(Convert.dmsToDecimalDegrees("34 45 36.2")!))")
//    }
//    
//    // http://www.convertalot.com/celestial_horizon_co-ordinates_calculator.html
//    class func testAltAz3() {
//        let dec = Convert.dmsToDecimalDegrees("-20 50 00")
//        let ra =  Convert.hmsToDecimalDegrees("17 48 00")
//        let lat = Convert.dmsToDecimalDegrees("37 53 00")
//        let lon = Convert.dmsToDecimalDegrees("-122 01 00")
//        let date = makeDate("2020-08-05 09:30:41 -0700")
//
//        let (alt,az) = Astro.altAz(ra:ra!, dec:dec!, date:date!, lat:lat!, lon:lon!)
//
//        print("alt = \(alt)")
//        print("az = \(az)")
//        print("UTC = \(date!)")
//        // desired result
//        // alt = -72.00264308649035
//        // az = 339.4610007651118
//        // UTC = Wed, 05 Aug 2020 16:30:41 GMT
//    }
    
}
