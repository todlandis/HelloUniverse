//
//  Macro.swift
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

class Macro {
    
    func process(_ s:String) {
        let start = s.index(s.startIndex, offsetBy: 1)
        let range = start..<s.endIndex
        let s = String(s[range]).trimmingCharacters(in: .whitespaces)
        print(s)
    }
    
    // copy a URL duplicating the current Hello Universe view
    func copyUrlToClipboard() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let aladin = appDelegate.aladinVC?.aladin else {
            return
        }
        
        aladin.getRaDec(completionHandler: {
            (ra,dec,error) in
            
            // version 1.1 won't read these underscores in a URL
            let coord = Convert.raDecToIcrs(ra:ra, dec:dec, underscored: true)
            
            aladin.getFov(completionHandler: {
                (w,h,error2) in
               // print(coord)
                let survey = aladin.getImageSurvey()
                let url = String(format:"hellouniverse://\(coord)?\(survey)?\(w)")
                let pasteboard = UIPasteboard.general
                pasteboard.url = URL(string:url)
            })
        })
    }
}
