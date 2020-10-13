//
//  Device.swift
//  HelloUniverse
//
//  Created by Tod Landis on 10/17/20.
//

import Foundation

import CoreMotion
import simd
import Accelerate

class DeviceAttitude {
    
    enum WhichWay {
        case backCamera
        case topOfPhone
    }
    
    var pointingDirection:WhichWay = .topOfPhone
    
    /*
     calculate Alt-Azimuth for the pointDirection in the current phone attitude
     this helps understand getting the angle between a line and a plane:
     https://www.superprof.co.uk/resources/academic/maths/analytical-geometry/distance/angle-between-line-and-plane.html
     */
    func calcAltAzimuth(motion:CMDeviceMotion) -> (alt:Double,az:Double) {
        // get the attitude of the phone as a quaternion
        let qMotion = motion.attitude.quaternion
        let q = simd_quatd(ix:qMotion.x,iy:qMotion.y,iz:qMotion.z,r:qMotion.w)
        
        // rotate a vector pointing in 'pointDirection' to match the phone attitude
        let vecBack = simd_act(q, simd_double3(0.0,0.0,-1.0))
        
        var vec:simd_double3
        switch(pointingDirection) {
        case .backCamera:
            vec = vecBack
        case .topOfPhone:
            vec = simd_act(q, simd_double3(0.0,1.0,0.0))
        }
        
        
        // altitude = the angle of pointDirection with the xy plane
        // take the plane normal, (0,0,1),
        // dot vec normalized to get
        // the cosine of the angle it makes with the normal.  Take the
        // complement of that angle to get the angle it makes witzh the plane and use cos(90 - angle) = sin(angle)
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
        return (alt,az)
    }
}
