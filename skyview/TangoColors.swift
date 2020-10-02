//
//  TangoColors.swift
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

// the Tango Palette
public class TangoColors {
    class func createColor255(r:Int, g:Int, b:Int, a:Int) -> UIColor {
        return UIColor(red:CGFloat(r)/CGFloat(255), green:CGFloat(g)/CGFloat(255), blue:CGFloat(b)/CGFloat(255), alpha:CGFloat(a))
    }
    
    public static let SKYBLUE = createColor255(r: 0x34, g: 0x65, b: 0xa4, a: 1)
    public static let LIGHT_SKYBLUE = createColor255(r: 0x72, g:0x9f, b:0xcf, a:1)
    public static let DARK_SKYBLUE = createColor255(r: 0x20, g:0x4a, b:0x87, a:1)
    
    public static let LIGHT_BUTTER = createColor255(r:0xfc, g:0xe9, b:0x4f, a:1)
    public static let BUTTER = createColor255(r: 0xed, g:0xd4, b:0x00, a:1)
    public static let DARK_BUTTER = createColor255(r: 0xc4, g:0xa0, b:0x00, a:1)
    
    public static let LIGHT_ALUMINUM = createColor255(r: 0xee, g:0xee, b:0xec, a:1)
    public static let ALUMINUM = createColor255(r: 0xd3, g:0xd7,b:0xcf, a:1)
    public static let DARK_ALUMINUM = createColor255(r: 0xba, g:0xbd, b:0xb6, a:1)
    
    public static let LIGHT_CHARCOAL = createColor255(r: 0x88, g:0x8a, b:0x85, a:1)
    public static let CHARCOAL = createColor255(r: 0x55, g:0x57, b:0x53, a:1)
    public static let DARK_CHARCOAL = createColor255(r: 0x2e, g:0x34, b:0x36, a:1)
    
    public static let LIGHT_TANGOORANGE = createColor255(r: 0xfc, g:0xaf, b:0x3e, a:1)
    public static let TANGOORANGE = createColor255(r: 0xf5, g:0x79, b:0x00, a:1)
    public static let DARK_TANGOORANGE = createColor255(r: 0xce, g:0x5c, b:0x00, a:1)
    
    public static let LIGHT_PLUM = createColor255(r: 0xad, g:0x7f, b:0xa8, a:1)
    public static let PLUM = createColor255(r: 0x75, g:0x50, b:0x7b, a:1)
    public static let DARK_PLUM = createColor255(r: 0x5c, g:0x35, b:0x66, a:1)
    
    public static let LIGHT_SCARLETRED = createColor255(r: 0xef, g:0x29, b:0x29, a:1)
    public static let SCARLETRED = createColor255(r: 0xcc, g:0x00, b:0x00, a:1)
    public static let DARK_SCARLETRED = createColor255(r: 0xa4, g:0x00, b:0x00, a:1)
    
    public static let LIGHT_CHAMELEON = createColor255(r: 0x8a, g:0xe2, b:0x34, a:1)
    public static let CHAMELEON = createColor255(r: 0x73, g:0xd2, b:0x16, a:1)
    public static let DARK_CHAMELEON = createColor255(r: 0x4e, g:0x9a, b:0x06, a:1)
    
    public static let LIGHT_CHOCOLATE = createColor255(r: 0xe9, g:0xb9, b:0x6e, a:1)
    public static let CHOCOLATE = createColor255(r: 0xc1, g:0x7d, b:0x11, a:1)
    public static let DARK_CHOCOLATE = createColor255(r: 0x81, g:0x59, b:0x02, a:1)
}
