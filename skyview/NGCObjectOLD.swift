//
//  NGCObject.swift
//  Created by Tod Landis on 4/6/22.
//
// see OpenNGCCatalog.swift

import Foundation

class NGCObjectOLD: Identifiable, Codable  {
    var id: UUID
    var name:String
    var ra:Double
    var dec:Double
    var type:String
    var const:String
    var majAx:Double
    var minAx:Double
    var posAng:Double
    var hubble:String
    var m:String
    
    init(name:String, ra:Double, dec:Double,type:String,const:String,majAx:Double,minAx:Double,posAng:Double,hubble:String,m:String) {
        self.id = UUID()
        self.name = name
        self.ra = ra
        self.dec = dec
        self.type = type
        self.const = const
        self.majAx = majAx
        self.minAx = minAx
        self.posAng = posAng
        self.hubble = hubble
        self.m = m
    }
    
}
