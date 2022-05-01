//
//  NGCObject.swift
//  HelloUniverse
//
//  Created by Tod Landis on 4/30/22.
//

import Foundation

// these are the fields HelloUniverse needs from OpenNGC
class NGCObject: Identifiable, Codable  {
    var id: UUID
    var name:String
    var x:Double
    var y:Double
    var z:Double
    var hubble:String
    var type:String
    var majAx:Double
    
    init(name:String, x:Double, y:Double,z:Double,type:String, hubble:String,majAx:Double) {
        self.id = UUID()
        self.name = name
        self.x = x
        self.y = y
        self.z = z
        self.type = type
        self.hubble = hubble
        self.majAx = majAx
    }
    
}
