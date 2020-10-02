//
//  Greek.swift
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

class Greek {
    static let codes = [
    ("alpha","\u{03B1}"),
    ("beta","\u{03B2}"),
    ("gamma","\u{03B3}"),
    ("delta","\u{03B4}"),
    ("epsilon","\u{03B5}"),
    ("zeta","\u{03B6}"),
    ("eta","\u{03B7}"),
    ("theta","\u{03B8}"),
    ("iota","\u{03B9}"),
    ("kappa","\u{03BA}"),
    ("lambda","\u{03BB}"),
    ("mu","\u{03BC}"),
    ("nu","\u{03BD}"),
    ("xi","\u{03BE}"),
    ("omicron","\u{03BF}"),
    ("pi","\u{03C0}"),
    ("rho","\u{03C1}"),
    ("varsigma","\u{03C2}"),
    ("sigma","\u{03C3}"),
    ("tau","\u{03C4}"),
    ("upsilon","\u{03C5}"),
    ("phi","\u{03C6}"),
    ("chi","\u{03C7}"),
    ("psi","\u{03C8}"),
    ("omega","\u{03C9}")
    ]
    
    // match the first two chars of 'letter' to a name here
    static func lookup(_ letter:String) -> (name:String, code:String)? {
        for (name,code) in codes {
            if (name.prefix(2) == letter.prefix(2).lowercased()) {
                return (name,code)
            }
        }
        return nil
    }
}
