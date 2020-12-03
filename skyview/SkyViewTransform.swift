//
//  SkyViewTransform.swift
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

import UIKit
import simd

class SkyViewTransform {
    var culling = true                    // see mapXYZ

    var decAngle:Double = 0.0           // degrees
    var raAngle:Double = 0.0            // degrees
    var latAngle:Double = 0.0           // degrees
    
    var translationVector = simd_double3(0,0,0)
    var rotationMatrix = matrix_identity_double3x3
    var inverseRotationMatrix = matrix_identity_double3x3
    
    
    // this makes a 2.5D projection and flips the z axis
    // x is 'right', y is 'into the screen', z is 'up',
    // y values will be used for culling
    var projectionMatrix:simd_double3x2 = simd_double3x2(simd_double2(1.0,0.0),simd_double2(0.0,0.0),simd_double2(0.0,-1.0))
    
    var scaleForStarView = 400.0
    var scale:Double = 400.0     // set for each draw
    
    var aladinWidth:Double = 0
    var aladinHeight:Double = 0
    var aladinCorners = [(ra:Double,dec:Double)](repeating:(0.0,0.0), count:4)

    // map (ra,dec) in degrees on the unit sphere to screen (x,y)
    func mapRAandDEC(ra:Double,dec:Double) -> CGPoint? {
        let raRadians = ra * Double.pi/180.0
        let decRadians = dec * Double.pi/180.0
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)
        return mapXYZ(simd_double3(X,Y,Z))
    }

    // map a point from space x,y,z to screen x,y
    //
    // the mapping consists of
    //           a translation in xyz
    //           a rotation in xyz
    //           projection to 2D
    //           a scaling
    func mapXYZ(_ pIn:simd_double3) -> CGPoint? {
        let pRotated = rotationMatrix * (pIn + translationVector)
        
        if(culling && pRotated.y < 0) {
            return nil          // culled
        }
        
        let pIn = scale * projectionMatrix * pRotated
        return CGPoint(x:pIn.x,y:pIn.y)
    }
    
    
    // set rotationMatrix so latAngle,decAngle is centered, pointing
    //    into the screen & calculate its inverse for unMap()
    func updateMatrices() {
        rotationMatrix = Matrix.rotationAroundY(degrees:latAngle) * Matrix.rotationAroundX(degrees:decAngle) * Matrix.rotationAroundZ(degrees:  raAngle-90.0)
        inverseRotationMatrix =
            Matrix.rotationAroundZ(degrees:  90.0 - raAngle) * Matrix.rotationAroundX(degrees:-decAngle) * Matrix.rotationAroundY(degrees:-latAngle)
    }

    func gotoRaDec(ra:Double,dec:Double) {
        decAngle = dec
        raAngle = ra
        updateMatrices()
    }
    
    func setSize(w:Double,h:Double) {
        print("ERROR SkyViewTransform is nut supported setSize \(w) \(h)")
    }
    

    func matchAladin(ra:Double, dec:Double , corners:[(ra:Double,dec:Double)], wPixels:Double, hPixels:Double) {
        func distance(_ p:CGPoint,_ q:CGPoint) -> Double {
            let x = p.x - q.x
            let y = p.y - q.y
            return Double(sqrt(x * x + y * y))
        }
        let remember = scale
        scale = 1.0
        
        let center = mapRAandDEC(ra: ra, dec: dec)
    
        let corner = mapRAandDEC(ra: corners[0].ra, dec: corners[0].dec)
        let desiredDistance = Double(sqrt(wPixels*wPixels + hPixels*hPixels)/2.0)
        if let center = center, let corner = corner {
            scale = desiredDistance/distance(corner,center)
        }
        else {
            // could return the new scale, with nil as a signal for "can't match"
            scale = remember
        }
    }
    
    func setAladinSizeAndCorners(width:Double, height:Double, corners:[(ra:Double,dec:Double)]) {
        aladinWidth = width
        aladinHeight = height
        aladinCorners = corners
        
        print("aladin dimensions")
        print(aladinWidth)
        print(aladinHeight)

        // map any corner and measure its distance from 0,0
        // remember the scale in case we have to put it back
        let restoreScale = scale
        
        scale = 1.0
        // p will be null if the corner is culled
        if let p = mapRAandDEC(ra: aladinCorners[0].ra, dec: aladinCorners[0].dec) {
            let len = Double(sqrt(p.x*p.x + p.y*p.y))

            // measure distance from the center to any corner of a rectangle
            // with width,height in aladin pixels
            let len2 = sqrt(aladinWidth*aladinWidth + aladinHeight*aladinHeight)/2.0

            // adjust the scale
            scale = (len2/len) * scale
            
            // hack
            scale = scale / 2.0
        }
        else {
            
            scale = restoreScale
        }
    }

}
