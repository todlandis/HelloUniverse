//
//  Annotations.swift
//  HelloUniverse
//
//  Created by Tod Landis on 11/6/20.
//

import UIKit

class Label {
    var text:String
    var ra:Double
    var dec:Double
    
    init(_ text:String, _ ra:Double, _ dec:Double) {
        self.text = text
        self.ra = ra
        self.dec = dec
    }
}

class Annotations: NSObject {
    var labels = [Label]()
    
    func addLabel(text:String, ra:Double, dec:Double) {
        labels.append(Label(text,ra,dec))
    }
    
    func clearLabels() {
        labels.removeAll()
    }

    // delete last label

}
