//
//  Matrix.swift
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
// 1.0

import simd


// https://developer.apple.com/documentation/accelerate/working_with_matrices
//
class Matrix {
    // https://en.wikipedia.org/wiki/Outer_product
    class func outer_product(a:simd_double3,b:simd_double3) -> simd_double3x3 {
        return simd_double3x3(rows:[
            a.x * b,
            a.y * b,
            a.z * b
        ])
    }
    
    // https://en.wikipedia.org/wiki/Cross_product#Conversion_to_matrix_multiplication
    // use cross(a,b) for the cross product
    class func cross_product_matrix(_ a: simd_double3) -> simd_double3x3 {
        let rows = [
         simd_double3(0.0, -a.z, a.y),
         simd_double3(a.z, 0.0, -a.x),
         simd_double3(-a.y, a.x, 0.0)
        ]
        return simd_double3x3(rows:rows)
    }
    
    // never used
    // this is the equation after "written more concisely" in
    // https://en.wikipedia.org/wiki/Rotation_matrix
    // u must be a unit vector
    class func rotationAroundU(u:simd_double3,degrees:simd_double1) -> matrix_double3x3{
        let theda = degrees * Double.pi/180.0
        let c = cos(theda)
        let m = c * matrix_identity_double3x3 + sin(theda) * cross_product_matrix(u) + (1.0 - c) * outer_product(a:u,b:u)
        print(m)
        return m
    }
    
    class func rotationAroundX(degrees: simd_double1) -> simd_double3x3 {
        let angle = degrees * Double.pi / 180.0
        let rows = [
            simd_double3( 1.0,          0.0,          0.0),
            simd_double3(0.0,   cos(angle), sin(angle)),
            simd_double3(0.0,   -sin(angle), cos(angle)),
        ]
        return simd_double3x3(rows: rows)
    }

    class func rotationAroundY(degrees: simd_double1) -> simd_double3x3 {
        let angle = degrees * Double.pi / 180.0
        let rows = [
            simd_double3( cos(angle), 0,  sin(angle)),
            simd_double3( 0,          1,          0),
            simd_double3(-sin(angle), 0,  cos(angle)),
        ]
        return double3x3(rows: rows)
    }

    class func rotationAroundZ(degrees: simd_double1) -> simd_double3x3 {
        let angle = degrees * Double.pi / 180.0
        let rows = [
            simd_double3( cos(angle), sin(angle), 0),
            simd_double3(-sin(angle), cos(angle), 0),
            simd_double3( 0,          0,          1)
        ]
        return double3x3(rows: rows)
    }
}
