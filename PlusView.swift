//
//  PlusView.swift
//
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

import UIKit

class PlusView: UIView {
    var lineWidth:CGFloat =  1.0
    var lineLength:CGFloat = 20.0
    var bullsEyeColor = UIColor.red.cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = false
    }
    
    
    override func draw(_ rect: CGRect) {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        let middleX = bounds.origin.x + bounds.size.width/2.0;
        
        // 10 is a fudge term - guessing that map view sets the region below the phone header
        let middleY = bounds.origin.y + bounds.size.height/2.0 + 10;
        context.setLineWidth(lineWidth)
        context.setStrokeColor(bullsEyeColor)
        
        // the center of the map appears to be lower by 10 from
        // the center of the map view?
        let halfWidth = lineLength/2.0
        let halfHeight = lineLength/2.0
        
        context.move(to:CGPoint(x:middleX - halfWidth, y:middleY))
        context.addLine(to:CGPoint(x:middleX + halfWidth, y:middleY))
        context.strokePath()
        
        context.move(to:CGPoint(x:middleX, y:middleY - halfHeight))
        context.addLine(to:CGPoint(x:middleX, y:middleY + halfHeight))
        context.strokePath()
    }
}

