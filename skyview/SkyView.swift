//
//  SkyView.swift
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

protocol SkyViewDelegate {
    func didTapSkyView()
    func didPanSkyView()
}

class SkyView: UIView {
    var delegate:SkyViewDelegate?
    // graphic attributes
    var constellationLineColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    var constellationLineWidth:CGFloat = 0.5
    
    var gridLineColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    let bullsEyeColor = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: CGFloat(0.6))

    var culling = true                    // see mapXYZ

    var translationVector = simd_double3(0,0,0)
    var decAngle:Double = 0.0           // degrees
    var raAngle:Double = 0.0            // degrees
    var latAngle:Double = 0.0
    var rotationMatrix = matrix_identity_double3x3
    var inverseRotationMatrix = matrix_identity_double3x3
    
    // this makes a 2.5D projection and flips the z axis
    // x is 'right', y is 'into the screen', z is 'up',
    // y values will be used for culling
    var projectionMatrix:simd_double3x2 = simd_double3x2(simd_double2(1.0,0.0),simd_double2(0.0,0.0),simd_double2(0.0,-1.0))
    
    var scaleForStarView = 400.0
    var scale:Double = 400.0     // set for each draw

    // see SkyViewVC.viewDidLoad()
    var settings:Settings? = nil
    
    var circlePoints = [(ra:Double,dec:Double)]()
    var boxPoints =    [(ra:Double,dec:Double)]()
    var plusPoints =    [(ra:Double,dec:Double)]()
    var aladinPlus:(ra:Double,dec:Double)? = nil
    
    // see AladinVC.viewWillDisappear()...this was the last field in Aladin
    var aladinCorners = [(ra:Double,dec:Double)]()
    
    // see drawCrossHairs() below
    var crossHairs:(ra:Double,dec:Double)? = nil
    
    var starLabels = [String]()  // deprecated
    
    var labels = [(s:String,(x:Double,y:Double,z:Double))]()
    
    var messierFont:UIFont? = nil
    var appDelegate:AppDelegate? = nil
    
    func setGestures(appDelegate:AppDelegate?) {
        self.appDelegate = appDelegate
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        addGestureRecognizer(pinch)
        
        //https://developer.apple.com/documentation/uikit/uihovergesturerecognizer
//        let hover = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
//        addGestureRecognizer(hover)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(tap)
    }
        
    override func draw(_ rect: CGRect) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        
        messierFont = UIFont(name: "Helvetica Neue", size: settings!.messierLabelSize)!
        
        UIColor.black.setFill()
        context.fill(bounds)
        
        context.saveGState()
        
        // the center of the screen is 0,0
        let b = self.bounds
        let cx = (b.maxX + b.minX) / 2.0
        let cy = (b.maxY + b.minY) / 2.0
        context.translateBy(x: cx, y: cy)

        scale = scaleForStarView
        drawStarView(rect)

//        print("scale = \(scale)")

        context.restoreGState()
    }
    
    var originalScale:Double = 1.0
    
    func getRaDec() -> (ra:Double,dec:Double) {
        return(raAngle,decAngle)
    }
    
    func gotoRaDec(ra:Double,dec:Double) {
        decAngle = dec
        raAngle = ra
        updateMatrices()
        setNeedsDisplay()
    }

    @objc
    func tapped(_ recognizer: UIPinchGestureRecognizer) {
        if let delegate = delegate {
            delegate.didTapSkyView()
        }

    }
    
    @objc
    func pinch(_ recognizer: UIPinchGestureRecognizer) {
        let scale = Double(recognizer.scale)
        switch recognizer.state {
        case .began:
            //          print("began")
            originalScale = scaleForStarView
            break
        case .changed:
            scaleForStarView = originalScale * scale
            self.setNeedsDisplay()
            break
        case .ended:
            //          print("ended")
            break
        default:
            //        print("unrecognized state")
            break
        }
    }
    
    let catalog = BrightStarCatalog.shared
    
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
    
    
    // set rotationMatrix so that latAngle,decAngle is centered, pointing
    //    into the screen & calculate its inverse for unMap()
    func updateMatrices() {
        rotationMatrix = Matrix.rotationAroundY(degrees:latAngle) * Matrix.rotationAroundX(degrees:decAngle) * Matrix.rotationAroundZ(degrees:  raAngle-90.0)
        inverseRotationMatrix =
            Matrix.rotationAroundZ(degrees:  90.0 - raAngle) * Matrix.rotationAroundX(degrees:-decAngle) * Matrix.rotationAroundY(degrees:-latAngle)
    }
    

    // set content mode to "Redraw" so resizes trigger a redraw
    func drawStarView(_ dirtyRect: CGRect) {
        guard let settings = settings else {
            print("ERROR missing setings for SkyView")
            return
        }

        updateMatrices()
        scale = scaleForStarView
     //   print("scale = \(scale)")
        translationVector = simd_double3(0,0,0)
                        
        if settings.drawGrid { drawGridLinesF() }
        
        drawStars()
        
        if settings.drawPlusSigns {
            drawCenterPlus()
        }


        // annotations
        drawPlusPoints()
        
        if(settings.drawMessier) { drawMessierObjects() }
        
//        drawCirclePoints()
//        drawBoxPoints()
//        drawLabels()
//
        if(settings.drawFOV) { drawFieldOfView()}

        if(settings.drawAladin) { drawAladinCorners() }
        if(settings.drawBullsEye) { drawBullsEyeF() }

        if(settings.drawConstellationLines) { drawConstellationLinesF() }
        if(settings.drawConstellationNames) { drawConstellationNamesF() }
        
//        if(drawSpecialObjectsList) {
//            drawSpecialObjects()
//        }
 //       screenLines.draw(view:self)
    }
    
    func drawGridLinesF() {
        gridLineColor.setStroke()

        // LATER:  precalculate cos(decRadians) and sin(decRadians)
//        let num = 100
//        var cosines = [Double]()
//        var sines = [Double]()
//        for _ in 0...num {
//        }

        for a in [-75, -60.0,-45.0, -30.0, -15.0, 0.0, 15.0, 30.0, 45.0, 60.0,75.0] {
            let curve4 = generateCircleOfDeclination(angle: a)
            strokeCurve(curve4)
        }
//        let curve8 = generateCircleOfDeclination(angle: 0.0)
//        strokeCurve(curve8)
        
        for a in [  -165.0, -150.0, -135, -120, -105, -90.0,-75.0,-60.0,-45.0, -30.0,-15.0, 0.0, 15.0, 30.0,45.0,60.0,75.0,90,105.0,120,135.0,150,165.0, 180] {
            let curve4 = generateArcOfRightAscension(angle: a)
            strokeCurve(curve4)
        }
//        let curve10 = generateArcOfRightAscension(angle: 0.0)
//        strokeCurve(curve10)
    }
    
    // make a circle at declination = angle
    func generateCircleOfDeclination(angle:Double) -> [simd_double3] {
        var points = [simd_double3]()
        let num = 100
        let del = 2.0 * Double.pi / Double(num)
        var ra = 0.0
        
        
        let decRadians = angle * Double.pi/180.0    // -90 to 90 gives a range of 180 in
        for _ in 0...num {
            let X = cos(ra) * cos(decRadians)
            let Y = sin(ra) * cos(decRadians)
            let Z = sin(decRadians)
            points.append(simd_double3(X,Y,Z))
            ra = ra + del
        }
        return points
    }
    
    // make an arc at right ascension = angle
    func generateArcOfRightAscension(angle:Double) -> [simd_double3] {
        var points = [simd_double3]()
        let num = 100
        let del = Double.pi / Double(num)
        var dec = -Double.pi/2.0
        
        let raRadians = angle * Double.pi/180.0   // 0 - 360 in
        for _ in 0...num { //hack {
            let X = cos(raRadians) * cos(dec)
            let Y = sin(raRadians) * cos(dec)
            let Z = sin(dec)
            points.append(simd_double3(X,Y,Z))
            dec = dec + del
        }
        return points
    }
    
    // stroke the parts of 'curve' that are not culled for being in the front
    //   half of the sphere.
    func strokeCurve(_ curve:[simd_double3]) {
        func drawSegmentStartingFrom(_ iIn:Int)  -> Int {
            guard let context:CGContext = UIGraphicsGetCurrentContext() else {
                print("ERROR could not get a context")
                return curve.count
            }
            // find a first non-culled point
            var p0:CGPoint? = nil
            var i = iIn
            while(p0 == nil && i < curve.count) {
                p0 = mapXYZ(curve[i])
                i = i+1
            }
            if(p0 == nil) {
                return i
            }
            context.move(to: CGPoint(x: p0!.x,y: p0!.y))
            
            for j in i..<curve.count {
                let p = mapXYZ(curve[j])
                if(p == nil) {
                    // we are hidden
                    if(j != i) {
                        context.strokePath()
                    }
                    return j
                }
                context.addLine(to: CGPoint(x: p!.x,y: p!.y))
            }
            context.strokePath()
            return curve.count
        }
        
        let i = drawSegmentStartingFrom(0)
        if(i < curve.count) {
            _ = drawSegmentStartingFrom(i)
        }
    }
    
    func drawAxes() {
        UIColor.red.setStroke()
        let p0 = simd_double3(0.0,0.0,0.0)
        let px = simd_double3(1.0,0.0,0.0)
        strokeCurve([p0,px])
        let py = simd_double3(0.0,1.0,0.0)
        strokeCurve([p0,py])
        let pz = simd_double3(0.0,0.0,1.0)
        strokeCurve([p0,pz])
    }
    
    // the plane of xy is the RA plane, the positive x axis is north=0, degrees increase clockwise
    func drawStars() {
        let catalog = BrightStarCatalog.shared
        
        if let settings = settings {
            settings.starColor.setFill()
        }
        
        let stars = catalog.queryForStarsWhere("where ra != 'NULL' and dec != 'NULL'")

        for star in stars {
            plotStar(star)
        }
    }
    

    func circleStarNamed(name:String) {
        let catalog = BrightStarCatalog.shared
        guard let star = catalog.starNamed(name)  else {
            print("Could not find \(name)")
            return
        }
        circlePoints.append((star.ra,star.dec))
    }
    func circleRAandDEC(ra:Double,dec:Double) {
        circlePoints.append((ra,dec))
    }
    func drawCirclePoints() {
        for (ra,dec) in circlePoints {
            circlePoint(ra: ra,dec: dec)
        }
    }

    
    func labelAt(ra:Double,dec:Double,label:String, color:UIColor) {
        if let p = mapRAandDEC(ra:ra,dec:dec) {
            let font:UIFont = UIFont(name: "Helvetica Neue", size: 18.0)!
            let attributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : font, NSAttributedString.Key.foregroundColor : color]
            label.draw(at:CGPoint(x: p.x + 10,y: p.y - 10), withAttributes: attributes)
        }
    }
    
    func plusRAandDEC(ra:Double,dec:Double) {
        plusPoints.append((ra,dec))
    }
    
    func drawPlusPoints() {
        for (ra,dec) in plusPoints {
            plusPoint(ra: ra,dec: dec)
        }
    }
    
    func drawCenterPlus() {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        TangoColors.SCARLETRED.setStroke()
        context.setLineWidth(2.0)
        
        let p = CGPoint(x: 0.0,y: 0.0)
        
        let half_size = CGFloat(12.0)
        context.move(to: CGPoint(x: p.x - half_size,y: p.y))
        context.addLine(to: CGPoint(x: p.x + half_size,y: p.y))
        context.strokePath()

        context.move(to: CGPoint(x: p.x, y: p.y - half_size))
        context.addLine(to: CGPoint(x: p.x, y: p.y + half_size))
        context.strokePath()
    }
    
    func drawMessierObjects() {
        let catalog = BrightStarCatalog.shared
        _ = catalog.open()
        let mess = catalog.getMessierObjects()
        
        for m in mess {
            plotMessier(label:m.name, x:m.xs,y:m.ys,z:m.zs)
        }
        catalog.close()
    }
    
    func boxRAandDEC(ra:Double,dec:Double) {
        boxPoints.append((ra,dec))
    }
    func drawBoxPoints() {
        for (ra,dec) in boxPoints {
            boxPoint(ra: ra,dec: dec)
        }
    }

//    func drawLabels() {
//        for name in starLabels {
//            labelStar(name)
//        }
//    }
    
    // draw lines given their endpoints in ra,dec, used e.g. by drawAladinCorners()
    func drawLines(_ vals:[(Double,Double,Double,Double)]?) {
        if (vals != nil) {
            for val in vals! {
                var raRadians = val.0 * Double.pi/180.0
                var decRadians = val.1 * Double.pi/180.0
                var X = cos(raRadians) * cos(decRadians)
                var Y = sin(raRadians) * cos(decRadians)
                var Z = sin(decRadians)
                
                guard let p1 = mapXYZ(simd_double3(X,Y,Z)) else {
                    return
                }
                raRadians = val.2 * Double.pi/180.0
                decRadians = val.3 * Double.pi/180.0
                X = cos(raRadians) * cos(decRadians)
                Y = sin(raRadians) * cos(decRadians)
                Z = sin(decRadians)
                guard let p2 = mapXYZ(simd_double3(X,Y,Z)) else {
                    return
                }
                plotLine(p1,p2)
            }
        }
    }
    
    func getFov() -> Double {
        let pOrigin = CGPoint(x: 0,y: 0)
        let pCorner = CGPoint(x:bounds.size.width,y:bounds.size.height)
        if let (raOrigin, decOrigin) = unMap(pOrigin),
            let (raCorner,decCorner) = unMap(pCorner) {
            let raDif = raCorner - raOrigin
            let decDif = decCorner - decOrigin
            return max(raDif,decDif)
        }
        return Double.nan
    }

    func drawBullsEyeF() {
        guard let context = UIGraphicsGetCurrentContext(),
              let crossHairs = crossHairs else {
            return
        }

        guard let center = mapRAandDEC(ra: crossHairs.ra,dec: crossHairs.dec) else {
            // e.g. the point was culled
            return
        }
      
        let PI = CGFloat(Float.pi)
        
        bullsEyeColor.setStroke()
        context.setLineWidth(3.0)
        
        var gap:CGFloat
//        let radius1 =  CGFloat(40.0)
//        var gap = CGFloat(PI/24.0)        // degrees on each side
//        context.addArc(center: center, radius: radius1, startAngle: gap, endAngle: PI/2.0 - gap, clockwise: false)
//        context.strokePath()
//        context.addArc(center: center, radius: radius1, startAngle: PI/2.0 + gap, endAngle: PI - gap, clockwise: false)
//        context.strokePath()
//        context.addArc(center: center, radius: radius1, startAngle: PI + gap, endAngle: 3*PI/2.0 - gap, clockwise: false)
//        context.strokePath()
//        context.addArc(center: center, radius: radius1, startAngle: 3*PI/2.0 + gap, endAngle: 2*PI - gap, clockwise: false)
//        context.strokePath()

        let radius2 =  CGFloat(24.0)
        gap = CGFloat(PI/16.0)        // degrees on each side
        context.addArc(center: center, radius: radius2, startAngle: gap, endAngle: PI/2.0 - gap, clockwise: false)
        context.strokePath()
        context.addArc(center: center, radius: radius2, startAngle: PI/2.0 + gap, endAngle: PI - gap, clockwise: false)
        context.strokePath()
        context.addArc(center: center, radius: radius2, startAngle: PI + gap, endAngle: 3*PI/2.0 - gap, clockwise: false)
        context.strokePath()
        context.addArc(center: center, radius: radius2, startAngle: 3*PI/2.0 + gap, endAngle: 2*PI - gap, clockwise: false)
        context.strokePath()
        
        let radius3 =  CGFloat(12.0)
        context.addArc(center: center, radius: radius3, startAngle: gap, endAngle: PI * 2.0, clockwise: false)
        context.strokePath()
    }
    
    // draw a box around the Aladin field
    func drawAladinCorners() {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }

        TangoColors.TANGOORANGE.setStroke()
        context.setLineWidth(3.0)
        if(aladinCorners.count == 4) {
            var lines = [(Double,Double,Double,Double)]()
            lines.append((aladinCorners[0].ra,aladinCorners[0].dec,aladinCorners[1].ra,aladinCorners[1].dec))
            lines.append((aladinCorners[1].ra,aladinCorners[1].dec,aladinCorners[2].ra,aladinCorners[2].dec))
            lines.append((aladinCorners[2].ra,aladinCorners[2].dec,aladinCorners[3].ra,aladinCorners[3].dec))
            lines.append((aladinCorners[3].ra,aladinCorners[3].dec,aladinCorners[0].ra,aladinCorners[0].dec))
            drawLines(lines)
        }
    }
    
    func drawConstellationNamesF() {
        let catalog = BrightStarCatalog.shared
        _ = catalog.open()
        if let names = catalog.getConstellationNames() {
            for n in names {
                plotLabel(n.x, n.y, n.z, n.name,settings!.constellationLabelSize)
            }
        }
        catalog.close()
    }

    func drawConstellationLinesF() {
        func drawLine(_ first:(x:Double,y:Double,z:Double),_ second:(x:Double,y:Double,z:Double)) {
            guard let p1 = mapXYZ(simd_double3(first.x,first.y,first.z)) else {
                return
            }
            guard let p2 = mapXYZ(simd_double3(second.x,second.y,second.z)) else {
                return
            }
            plotLine(p1,p2)
        }
    
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        constellationLineColor.setStroke()
        context.setLineWidth(constellationLineWidth)

        let catalog = BrightStarCatalog.shared
        _ = catalog.open()
        if let lines = catalog.getConstellationLines() {
            for line in lines {
                drawLine(line.first, line.second)
            }
        }
        catalog.close()
    }
    
    func drawFieldOfView() {
        let curve = fieldOfViewPoints()

        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        context.setLineWidth(2.0)
        TangoColors.LIGHT_SKYBLUE.setStroke()

        strokeCurve(curve)
    }
    
    func setAladinCorners(_ corners:[(ra:Double,dec:Double)] ){
        aladinCorners = corners
    }
    
    func setPhoneCrossHairs(ra:Double,dec:Double) {
        crossHairs = (ra,dec)
    }

    func setFov(_ val:Double) {
        let cur = getFov()
        let ratio = val / cur
        if (!val.isNaN) {
            scale = scale * ratio
            setNeedsDisplay()
        }
    }
    
    func fieldOfViewPoints() -> [simd_double3] {
        let scope = Telescope.shared
        let eyepiece = scope.eyepiece
        let fov = scope.calcTrueFOV(eyepiece) //was 5.5;
  //      print("fov = \(fov)")
        let radiusAngle = fov  // was 5.5;

        var points = [simd_double3]()
        let num = 100

        let del = 2.0 * Double.pi / Double(num)
        var ra = 0.0

        let decRadians = (90 - radiusAngle) * Double.pi/180.0    // -90 to 90 gives a range of 180 in


        let matrix =  Matrix.rotationAroundZ(degrees: 90 - raAngle) * Matrix.rotationAroundX(degrees: 90 - decAngle)

        for _ in 0...num {
            let X = cos(ra) * cos(decRadians)
            let Y = sin(ra) * cos(decRadians)
            let Z = sin(decRadians)
            var p = simd_double3(X,Y,Z)
            p = matrix * simd_double3(X,Y,Z)
            points.append(p)
            ra = ra + del
        }
        return points
    }
    
    func plotLine(_ f:CGPoint?,_ s:CGPoint?) {
        guard let f=f,let s=s else {
            return
        }
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        context.move(to: f)
        context.addLine(to: s)
        context.strokePath()
    }
    
    func labelStars(_ stars:[String]) {
        for s in stars {
            labelStar(s)
        }
    }
    
    func labelStar(_ name:String) {
        guard let star = catalog.starNamed(name)  else {
            return
        }

        //TODO this could be map(ra,dec)
        let raRadians = star.ra * Double.pi/180.0
        let decRadians = star.dec * Double.pi/180.0
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)
        
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }
        
        let font:UIFont = UIFont(name: "Helvetica Neue", size: settings!.starNameLabelSize)!
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : font, NSAttributedString.Key.foregroundColor : UIColor.white]
        
        var s:String
        if(star.commonName != "") {
            s = star.commonName
        }
        else {
            s = star.name
        }
        
        s.draw(at:CGPoint(x: p.x + 10,y: p.y - 20), withAttributes: attributes)
    }
        
    func greekToString(_ greek:String) -> String {
        if let (name,code) = Greek.lookup(greek) {
            var label:String = ""
            if(name.count == 2) {
                // e.g. "mu" "xi" "pi3"
                // replace two characters with unicode 'code'
                //                    print("\(greek)  \(greek.suffix(greek.count - 2))")
                label = code + greek.suffix(greek.count - 2)
            }
            else {
                // e.g. 'alp' or 'bet'
                //                    print("\(greek)  \(greek.suffix(greek.count - 3))")
                label = code + greek.suffix(greek.count - 3)
            }
            return label
//            label.draw(at:CGPoint(x: p.x + 10,y: p.y - 20), withAttributes: attributes)
        }
        else {
            return ""
        }
    }
    
    // draw a circle around ra,dec
    func circlePoint(ra:Double,dec:Double) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        let raRadians = ra * Double.pi/180.0
        let decRadians = dec * Double.pi/180.0
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)
        
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }

        TangoColors.TANGOORANGE.setStroke()
        context.setLineWidth(2.0)
        let size = CGFloat(12)
        let r = CGRect(x: CGFloat(p.x)-size/2, y: CGFloat(p.y)-size/2, width: size, height: size)
        context.addEllipse(in: r)
        context.strokePath()
    }
        
    func plusPoint(ra:Double,dec:Double, color:UIColor = TangoColors.TANGOORANGE) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        let raRadians = ra * Double.pi/180.0
        let decRadians = dec * Double.pi/180.0
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)
        
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }

        color.setStroke()
        let half_size = CGFloat(10.0)
        context.move(to: CGPoint(x: p.x - half_size,y: p.y))
        context.addLine(to: CGPoint(x: p.x + half_size,y: p.y))
        context.strokePath()

        context.move(to: CGPoint(x: p.x, y: p.y - half_size))
        context.addLine(to: CGPoint(x: p.x, y: p.y + half_size))
        context.strokePath()
    }
    
    func boxPoint(ra:Double,dec:Double) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        let raRadians = ra * Double.pi/180.0
        let decRadians = dec * Double.pi/180.0
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)
        
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }

        TangoColors.TANGOORANGE.setStroke()
        let size = CGFloat(20)
        let r = CGRect(x: CGFloat(p.x)-size/2, y: CGFloat(p.y)-size/2, width: size, height: size)
        context.addRect(r)
        context.strokePath()
    }

    func plotMessier(label:String,x:Double,y:Double,z:Double) {
        // user can zoom in to see the labels
        if scale > 750.0 {
            plotLabel(x,y,z, label, font:messierFont!, color:settings!.messierColor)
        }
        diamondPoint(x: x,y: y,z: z)
    }
    
    func diamondPoint(x:Double,y:Double,z:Double) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
//        let raRadians = ra * Double.pi/180.0
//        let decRadians = dec * Double.pi/180.0
//        let X = cos(raRadians) * cos(decRadians)
//        let Y = sin(raRadians) * cos(decRadians)
//        let Z = sin(decRadians)
        
        guard let pIn = mapXYZ(simd_double3(x,y,z)) else {
            return
        }
        
        let p = CGPoint(x:pIn.x, y:pIn.y)
        
        TangoColors.TANGOORANGE.setFill()
        let size = CGFloat(4)
        context.move(to: CGPoint(x:p.x,y:p.y - size))
        context.addLine(to: CGPoint(x:p.x + size,y:p.y))
        context.addLine(to: CGPoint(x:p.x,y:p.y + size))
        context.addLine(to: CGPoint(x:p.x - size,y:p.y))
        context.addLine(to: CGPoint(x:p.x,y:p.y - size))
        context.fillPath()
    }

    func boxStar(_ star:(hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        // code shared with plot
//        let ra = star.ra * 365.0/24.0  // this should bo away
        let raRadians = star.ra * Double.pi/180.0
        let decRadians = star.dec * Double.pi/180.0
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)
        
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }

        TangoColors.TANGOORANGE.setStroke()
        let size = CGFloat(20)
        let r = CGRect(x: CGFloat(p.x)-size/2, y: CGFloat(p.y)-size/2, width: size, height: size)
        context.addRect(r)
        context.strokePath()
    }
    
    func magnitudeToSize(_ magnitude:Double, zoomed:Bool) -> CGFloat {
        var size:Double
        var mags:[Double]
        if zoomed {
            mags = [5.0, 3.0, 1.5, 1.5]   // 1.5 is smallest visible
        }
        else {
            mags = [5.0, 2.0, 1.5, 0.5]           // > mag 5
        }
        
        if(magnitude < 3.5) {
            size = mags[0]
        }
        else if (magnitude < 4) {
            size = mags[1]
        }
        else if (magnitude < 5) {
            size = mags[2]
        }
        else {
            size = mags[3]
        }
        return CGFloat(size)
    }
    
    func plotStar(_ star:Star) {
        guard let settings = settings else {
            print("ERROR missing setings for SkyView")
            return
        }

        // pre-culling
        if let w = Astro.raDecToXYZ(ra: raAngle, dec: decAngle) {    // do this once per draw
            let v = simd_double3(star.xs,star.ys,star.zs)      // save this
            let dotted = dot(v,w)                  // cosine of angle between v and w
            if dotted < 0 {
                return
            }
        }
        
        let X = star.xs
        let Y = star.ys
        let Z = star.zs
        
        let size = magnitudeToSize(star.magnitude, zoomed: scale > 1000)
        
//FASTER:  XYZ is mapped twice:  once for star, once for label
        plotXYZ(X,Y,Z,size)

        let g = greekToString(star.greek)
        if(settings.drawBayer) {
            plotLabel(X,Y,Z, g, settings.constellationLabelSize)
        }
        
        if(settings.drawCommonNames && (g == "α" || scale > 1000.0)) {
            plotLabel(X,Y,Z,star.commonName,settings.starNameLabelSize)
        }
        
        if(settings.drawMagnitude && star.magnitude <= 5.0) {
            plotLabel(X,Y,Z, String(format:"%.1f",star.magnitude))
        }
    }

    // this is going away
    func plotLabel(_ X:Double,_ Y:Double,_ Z:Double,_ label:String, _ size:CGFloat = 24.0, color:UIColor = TangoColors.LIGHT_CHARCOAL) {
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }
        let size_2 = CGFloat(size/2.0)
        // do this once per draw
        let font:UIFont = UIFont(name: "Helvetica Neue", size: size)!
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : font, NSAttributedString.Key.foregroundColor : color]
        if label.count > 0 {
            label.draw(at:CGPoint(x: p.x + size_2,y: p.y - size_2), withAttributes: attributes)
        }
    }

    func plotLabel(_ X:Double,_ Y:Double,_ Z:Double,_ label:String, font:UIFont, color:UIColor) {
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }
//        let size_2 = Double(size/2.0)
//        // do this once per draw
//        let font:UIFont = UIFont(name: "Helvetica Neue", size: size)!
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : font, NSAttributedString.Key.foregroundColor : color]
        
        let space = font.lineHeight / 2.0
        if label.count > 0 {
            label.draw(at:CGPoint(x: p.x + space, y: p.y - space), withAttributes: attributes)
        }
    }
    
    func plotXYZ(_ X:Double,_ Y:Double,_ Z:Double,_ size:CGFloat) {
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            print("ERROR could not get a context")
            return
        }
        
        guard let p = mapXYZ(simd_double3(X,Y,Z)) else {
            return
        }

        let r = CGRect(x: CGFloat(p.x)-size/2, y: CGFloat(p.y)-size/2, width: size, height: size)
        context.addEllipse(in:r)
        context.fillPath()
    }
    
    // there are limitations, this reverse mappinggives funny results within
    // about 3 degrees of the north or south pole (dec = +/- 90)
    //            e.g. 180,-89   ->   nan,nan
    func testOLD () {
        print()
        print()
//        print(atan2(sin(0.0),cos(0.0)))
//        print(atan2(0.0,1.0))

        let raIn:Double =   180.0          // 0 to 360 allowed
        let decIn:Double = -87.0       // -90 to 90 allowed
        print("test put in \(raIn) \(decIn)")
        
        let raRadians:Double = raIn * Double.pi/180.0
        let decRadians:Double = decIn * Double.pi/180.0
        print("raRadians \(raRadians)   decRadians \(decRadians)")
        
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)                  // easy to recover decRadians!
                                                 // decRadians= asin(z)  asin returns a value in - pi/2 to pi/2
                                                 //    which matches the range of possible decRadians

        let q =   simd_double3(X,Y,Z)

        let qRotated =   rotationMatrix * q
//print("after rotating q \(qRotated)")
        
        let qProjected = projectionMatrix * qRotated
//        print("q2 after projecting \(qProjected)")
        
        let qUnprojected = simd_double3(qProjected.x, sqrt(1.0 - qProjected.x*qProjected.x - qProjected.y*qProjected.y),-qProjected.y)
 //       print("after unprojecting\(qUnprojected)")
 //       print("difference after unprojecting \(qUnprojected-qRotated)")
        
        let qUnrotated = inverseRotationMatrix * qUnprojected
 //       print("after unrotating XYZ = \(qUnrotated.x) \(qUnrotated.y) \(qUnrotated.z)")

        // https://en.wikipedia.org/wiki/Spherical_coordinate_system
        let raRadiansBack =  atan2(qUnrotated.y,qUnrotated.x)
        let  decRadiansBack = asin(qUnrotated.z)
        print("raRadiansBack \(raRadiansBack)  decRadiansBack \(decRadiansBack)")
        
        let raBack = raRadiansBack * 180.0/Double.pi
        let decBack = decRadiansBack * 180.0/Double.pi
        
        print("test get back ra = \(raBack)  dec = \(decBack)")
    }
    
    func test2() {
        let qProjected = simd_double2(x:0.0,y:0.0)
        let qUnprojected = simd_double3(qProjected.x, sqrt(1.0 - qProjected.x*qProjected.x - qProjected.y*qProjected.y),-qProjected.y)
        
        let qUnrotated = inverseRotationMatrix * qUnprojected
        
        // https://en.wikipedia.org/wiki/Spherical_coordinate_system
        let raRadiansBack =  atan2(qUnrotated.y,qUnrotated.x)
        let  decRadiansBack = asin(qUnrotated.z)
        print("raRadiansBack \(raRadiansBack)  decRadiansBack \(decRadiansBack)")
        
        let raBack = raRadiansBack * 180.0/Double.pi
        let decBack = decRadiansBack * 180.0/Double.pi
        
        print("test2  ra = \(raBack)  dec = \(decBack)")
    }
    
//    func raDecToXYZ(ra:Double,dec:Double) -> simd_double3? {
//        let raRadians = ra * Double.pi/180.0
//        let decRadians = dec * Double.pi/180.0
//        return simd_double3(cos(raRadians) * cos(decRadians),
//        sin(raRadians) * cos(decRadians),
//        sin(decRadians))
//    }

    // map (ra,dec) in degrees on the unit sphere to screen (x,y)
    func mapRAandDEC(ra:Double,dec:Double) -> CGPoint? {
        let raRadians = ra * Double.pi/180.0
        let decRadians = dec * Double.pi/180.0
        let X = cos(raRadians) * cos(decRadians)
        let Y = sin(raRadians) * cos(decRadians)
        let Z = sin(decRadians)
        return mapXYZ(simd_double3(X,Y,Z))
    }

    // map screen x,y back to x,y,z and then to ra,dec
    func unMap(_ pScreen:CGPoint) -> (ra:Double,dec:Double)? {
        let b = self.bounds
        let cx = (b.maxX + b.minX) / 2.0
        let cy = (b.maxY + b.minY) / 2.0
        
        let x = Double(pScreen.x - cx)/scale
        let y = Double(pScreen.y - cy)/scale
        
        // mapping back through the projection matrix.  The
        // the x- and z- values depend on the partiuclar projection matrix
        // then calculate y to make the length 1
        let qUnrotated = inverseRotationMatrix * simd_double3(x, sqrt(1.0 - (x*x + y*y)), -y)
       
        //next: use Astro's xyz to ra,dec
        var ra =  atan2(qUnrotated.y,qUnrotated.x) * 180.0/Double.pi
        if(ra < 0.0) {
            ra = ra + 360.0
        }
        let dec = asin(qUnrotated.z)     *  180.0/Double.pi
        return (ra,dec)
    }

//    func setCenterPoint(ra:Double,dec:Double) {
//        raAngle = ra
//        decAngle = dec
//        updateMatrices()
//        setNeedsDisplay()
//    }
    
    var lastTranslation = CGPoint(x: 0,y: 0)
    @objc
    func pan(_ recognizer: UIPanGestureRecognizer) {
        if let delegate = delegate {
            delegate.didPanSkyView()
        }

        //https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pan_gestures
        
        let translation = recognizer.translation(in: self)
        switch recognizer.state {
        case .began:
            lastTranslation = translation
            break
        case .changed:
            var deltaX = 90 * (translation.x - lastTranslation.x)/frame.width
            deltaX = deltaX * 400.0/CGFloat(scaleForStarView)
            
            var angle = raAngle + Double(deltaX)
            if(angle > 360.0) {
                angle = angle - 360
            }
            if(angle  < 0) {
                angle = angle + 360.0
            }
            raAngle = angle
            
            var deltaY = 90 * (translation.y - lastTranslation.y)/frame.height
            deltaY = deltaY * 400.0/CGFloat(scaleForStarView)
            angle = decAngle + Double(deltaY)

            // if the user pans past the North Pole or the South Pole, move
            // to the other side of the pole.
      //      var adjustRA = false
            if(angle > 90.0) {
                angle = 180 - angle
      //          adjustRA = true
            }
            if(angle  < -90) {
                angle = -180 - angle
       //         adjustRA = true
            }
            
//            if adjustRA {
//                raAngle = raAngle + 12.0
//                if raAngle > 24.0 {
//                    raAngle = raAngle - 24.0
//                }
//            }
            decAngle = angle
            lastTranslation = translation
            setNeedsDisplay()
            break
        case .ended:
//            print("ended")
            break
        default:
            print("unrecognized state")
            break
        }
    }

    func histogram(_ array:[Any], min:Double, max:Double, numberOfBuckets:Int) {
        var buckets = Array(repeating: 0.0, count: numberOfBuckets+1)
        let del = (max - min) / Double(numberOfBuckets)
        var mins = [Double]()
        var maxs = [Double]()
        var val = min
        while (val < max) {
            mins.append(val)
            val += del
            maxs.append(val)
        }
        
        for d in array {
            if let val = d as? Double {
                for i in 0..<mins.count {
                    if (val > mins[i] && val <= maxs[i]) {
                        buckets[i] = buckets[i] + 1
                    }
                }
            }
        }
        
        var sum = 0.0
        for i in 0..<buckets.count-1 {
            print(String(format:"%.2f-%.2f\t %.0f",mins[i],maxs[i],buckets[i]))
            sum = sum + buckets[i]
        }
        print("total \(sum)")
    }
}

// you can confirm transform values with astropy.py
//# https://docs.astropy.org/en/stable/coordinates/
//from astropy import units as u
//from astropy.coordinates import SkyCoord
//
//c = SkyCoord(ra=0*u.degree, dec=50*u.degree, distance=1*u.kpc)
//print(c.cartesian.x  )
//print(c.cartesian.y  )
//print(c.cartesian.z  )
    
