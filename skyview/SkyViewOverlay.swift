//
//  SkyViewOverlay.swift
//  HelloUniverse
//
//  Created by Tod Landis on 11/26/20.
//

import UIKit

class SkyViewOverlay: UIView {
    let color = UIColor.orange
    let font = UIFont(name: "Helvetica Neue", size: 20)!
    let skyViewTransform = SkyViewTransform()
    var annotations:Annotations
    var attributes:[NSAttributedString.Key : Any]?
    
    required init?(coder: NSCoder) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            annotations = appDelegate.annotations
        }
        else {
            annotations = Annotations()
        }
        attributes = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): self.font, NSAttributedString.Key.foregroundColor : color]

        super.init(coder:coder)
        self.backgroundColor = UIColor.black
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        context.saveGState()
        
        // the center of the screen is 0,0
        let b = self.bounds
        let cx = (b.maxX + b.minX) / 2.0
        let cy = (b.maxY + b.minY) / 2.0
        context.translateBy(x: cx, y: cy)

        for label in annotations.labels {
            if let p = skyViewTransform.mapRAandDEC(ra: label.ra, dec: label.dec) {
                label.text.draw(at:p, withAttributes: attributes)
            }
        }

        context.restoreGState()

        
    }
    
    func gotoRaDec(ra:Double, dec:Double) {
        skyViewTransform.gotoRaDec(ra: ra, dec: dec)
    }
    func matchAladin(ra:Double, dec:Double , aladin:Aladin) {
     //   print("overlay bounds:  \(bounds)")
        
        aladin.getSize(completionHandler:
                        {
                            wpixels,hpixels,error in
                        //    print("wPixels: \(wpixels)  hpixels:\(hpixels)")

                            if error == nil {                                            aladin.getFovCorners(completionHandler: {
                                vals,error in
                                if let corners = vals as? [(ra:Double,dec:Double)] {
                                    self.matchAladinC(ra:ra, dec:dec, corners:corners,wPixels:wpixels,hPixels:hpixels)
                                }
                            })
                            }})
    }
    
    func matchAladinC(ra:Double, dec:Double , corners:[(ra:Double,dec:Double)], wPixels:Double, hPixels:Double) {
        skyViewTransform.matchAladin(ra:ra, dec:dec , corners:corners, wPixels:wPixels, hPixels:hPixels)
        setNeedsDisplay()
    }
    
}
