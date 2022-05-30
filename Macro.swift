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
    
    func process(_ text:String) {
        let components = text.components(separatedBy: " ")
        let cmd = components[0]
        
        let startTail = text.index(text.startIndex, offsetBy: cmd.count)
        //            let end =   text.index(text.endIndex, offsetBy:0)
        let rangeTail = startTail..<text.endIndex
        let tail = String(text[rangeTail]).trimmingCharacters(in: .whitespaces)
        
        switch(cmd) {
        case ":l", ":L",":label":
            // add a label at the current center of the view
            labelCenter(tail)
            break
        case ":u", ":U",":url":
            copyUrlToClipboard()
            break
        case ":custom":
            customImageSurvey()
            break
        default:
            break
        }
    }
    
    func customImageSurvey() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let aladin = appDelegate.aladinVC?.aladin else {
            return
        }

        aladin.customImageSurvey()
    }

    // show() is no longer supported
 
    func labelCenter(_ text:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let aladin = appDelegate.aladinVC?.aladin else {
            return
        }


        aladin.getRaDec(completionHandler: {
            ra,dec,err in
            appDelegate.annotations.addLabel(text: text, ra: ra, dec: dec)
            //LATER annotations delegate sends out change notifications
            DispatchQueue.main.async {
                appDelegate.aladinVC?.whoIsThatBehindTheScreen.setNeedsDisplay()
                appDelegate.skyViewVC?.skyView.setNeedsDisplay()
            }
        })

    }
    // copy a URL duplicating the current Hello Universe view
    func copyUrlToClipboard() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let aladin = appDelegate.aladinVC?.aladin else {
            return
        }
        
        aladin.getRaDec(completionHandler: {
            (ra,dec,error) in
            
            // versiaon 1.1 won't read these underscores in a URL
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
