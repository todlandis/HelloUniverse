//
//  BrightStarCatalog.swift
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
// 1.0

import UIKit
import SQLite3

class BrightStarCatalog : SqliteDatabase {
    var verbose = true
    
    static let shared: BrightStarCatalog = {
        let instance = BrightStarCatalog()
        return instance
    }()


    init() {
        guard let fileUrl = Bundle.main.url(forResource: "bsc5", withExtension: "db") else {
            super.init("")
            print("ERROR bcs5.db was not in the bundle")
            sqlError()
            return
        }
        if(verbose) {
            print("BrightStarCatalog fileUrl = \(fileUrl)")
        }
        
        super.init(fileUrl.absoluteString)
    }
    
//    // calculate ra,dec in messier_list to decimal values using raHMS,decDMS
//    func updateMessierRaDec() {
//        _ = open()
//        var statement: OpaquePointer? = nil
//        if (sqlite3_prepare_v2(database, "select m,raHMS,decDMS from messier_wiki", -1, &statement, nil) != SQLITE_OK) {
//            sqlError();
//        }
//        else {
//            var more:Bool = true
//            repeat {
//                let state = sqlite3_step(statement)
//                if (state == SQLITE_ROW) {
//                    var m = ""
//                    if let tmp = sqlite3_column_text(statement, 0) {
//                        m = String(cString:tmp)
//                    }
//
//                    // the abbrev is in 1
//                    var raHMS = ""
//                    if let tmp = sqlite3_column_text(statement, 1) {
//                        raHMS = String(cString:tmp)
//                    }
//
//                    var decDMS = ""
//                    if let tmp = sqlite3_column_text(statement, 2) {
//                        decDMS = String(cString:tmp)
//                    }
//
//                    if let ra = Convert.hmsToDecimalDegrees(raHMS),let dec = Convert.dmsToDecimalDegrees(decDMS) {
//                        print("\(m)\t\(ra)\t\(dec)")
//                    }
//                    else {
//                        print("ERROR")
//                    }
//
//                }
//                else {
//                    more = false
//                }
//            } while(more)
//        }
//        sqlite3_finalize(statement);
//        close()
//    }
        
    func getMessierObjects() -> [(name:String,xs:Double,ys:Double,zs:Double)] {
        var points = [(name:String,xs:Double,ys:Double,zs:Double)]()

        var statement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database, "select m,ra,dec from messier_list", -1, &statement, nil) != SQLITE_OK) {
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    var num = ""
                    if let h = sqlite3_column_text(statement, 0) {
                        num = String(cString:h)
                    }
                    else if(verbose) {
//                        print("ERROR a constellation name was missing")
                        continue
                    }
                    
                    // the abbrev is in 1
                    let ra = sqlite3_column_double(statement, 1)
                    let dec = sqlite3_column_double(statement, 2)
                    
                    // computatinos could be cached in the table
                    let raRadians = ra * Double.pi/180.0
                    let decRadians = dec * Double.pi/180.0
                    let X = cos(raRadians) * cos(decRadians)
                    let Y = sin(raRadians) * cos(decRadians)
                    let Z = sin(decRadians)
              
                    points.append((num,X,Y,Z))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return points
    }
    
    // read names and x,y,z
    func getConstellationNames() -> [(name:String, x:Double,y:Double,z:Double)]? {
        
        var names = [(name:String,x:Double,y:Double,z:Double)]()
        
        var statement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database, "select * from const", -1, &statement, nil) != SQLITE_OK) {
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    var name = ""
                    if let h = sqlite3_column_text(statement, 0) {
                        name = String(cString:h)
                    }
                    else if(verbose) {
//                        print("ERROR a constellation name was missing")
                        continue
                    }
                    
                    // the abbrev is in 1
                    let ra = sqlite3_column_double(statement, 2)
                    let dec = sqlite3_column_double(statement, 3)
                    
                    // computatinos could be cached in the table
                    let raRadians = ra * Double.pi/180.0
                    let decRadians = dec * Double.pi/180.0
                    let X = cos(raRadians) * cos(decRadians)
                    let Y = sin(raRadians) * cos(decRadians)
                    let Z = sin(decRadians)
              
                    names.append((name,X,Y,Z))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return names;
    }

    
    // read names and 6-tuples from table EndPoints
    func getConstellationLines() -> [(name:String, first:(x:Double,y:Double,z:Double),second:(x:Double,y:Double,z:Double))]? {
        var points = [(name:String,first:(x:Double,y:Double,z:Double),second:(x:Double,y:Double,z:Double))]()
        
        var statement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database, "select * from EndPoints", -1, &statement, nil) != SQLITE_OK) {
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    var name = ""
                    if let h = sqlite3_column_text(statement, 0) {
                        name = String(cString:h)
                    }
                    else if(verbose) {
                        print("ERROR a constellation name was missing")
                    }
                    
//                    //HACK
//                    if name == "Cas" {
//                        print("Cas")
//                        continue
//                    }

                    let x1 = sqlite3_column_double(statement, 1)
                    let y1 = sqlite3_column_double(statement, 2)
                    let z1 = sqlite3_column_double(statement, 3)
                    
                    let x2 = sqlite3_column_double(statement, 4)
                    let y2 = sqlite3_column_double(statement, 5)
                    let z2 = sqlite3_column_double(statement, 6)
                    
                    points.append((name,(x1,y1,z1),(x2,y2,z2)))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return points;
    }
    
    // e.g. "Alp Ori"
    func lookupBayerName(greek:String,constellation:String) -> (hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)? {
        let sql = " select  hr,name,ra,dec,magnitude,commonName,greek from stars where greek like '\(greek)' and lower(constellation) like '\(constellation.lowercased())';"
        return queryForStar(sql:sql)
    }

    func lookupConstellationNumber(number:String, constellation:String) ->
        (hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)? {
            let sql = " select  hr,name,ra,dec,magnitude,commonName,greek from stars where upper(num) like '\(number.uppercased())' and lower(constellation) like '\(constellation.lowercased())';"
           // print(sql)
            return queryForStar(sql:sql)
    }

    func starNamed(_ name:String) -> Star? { //(hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)?
        
        if(name.prefix(2).uppercased() == "HR") {
            return queryForOneStarWhere("where hr = \(name.suffix(name.count - 2))")
        }
        let uname = name.uppercased()
        if let p = queryForOneStarWhere("where upper(commonName) like '\(uname)'") {
            return p
        }
        return queryForOneStarWhere("where name like '\(name)'")
    }
    
    func starWithHR(_ hr:Int) -> (hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)? {
        return queryForStar(sql:"select hr,name,ra,dec,magnitude,commonName,greek from stars where hr = \(hr)")
    }
    
    // whereIn should be a where clause, including the word "where"
    func queryForOneStarWhere(_  whereIn:String) -> Star? {
        let arr = queryForStarsWhere(whereIn)
        if(arr.count > 0) {
            return arr[0]
        }
        else {
            return nil
        }
    }
    

    // selects stars matching 'where', which can be empty for about 9000 results
    func queryForStarsWhere(_  whereIn:String) -> [Star] {
        _ = open()
        var ret = [Star]()
        let arr = query(sql:
        """
        select hr,ra,dec,magnitude,spectralType,commonName,num,greek,constellation,spec,lumin,parsecs,ly,xs,ys,zs from stars \(whereIn)
        """ )
        close()
        for p in arr {
            let star = Star()
            star.hr = Int(p.hr)!
            star.ra = p.ra
            star.dec = p.dec
            star.magnitude = p.magnitude
            star.spectralType = p.spectralType
            star.commonName = p.commonName
            star.num = p.num
            star.greek = p.greek
            star.constellation = p.constellation
            star.spec = p.spec
            star.lumin = p.lumin
            star.ly = p.ly
            star.xs = p.xs
            star.ys = p.ys
            star.zs = p.zs
            ret.append(star)
        }
        return ret
    }

    func queryForStar(sql:String) -> (hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)? {
        let stars = queryForMatchingStars(sql:sql)
        if(stars.count == 0) {
            return nil
        }
        else {
            return stars[0]
        }
    }
    
//    func getVOTable(named:String) -> VOTable {
//        return VOTable(fields:[FIELDElement](),data:[[Any]]())
//    }
    
//
    // deprecated
    func queryForMatchingStars(sql:String) -> [(hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)] {
        _ = open()
        let arr = queryForStars(sql: sql)
        close()
        return arr
    }
    
    // must open first
    func queryForStars(sql:String) -> [(hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)] {
        var ret = [(hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)]()
        
        var statement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    var commonS = ""
                    if let s = sqlite3_column_text(statement, 5) {
                        commonS = String(cString:s)
                    }
                    var nameS = ""
                    if let n = sqlite3_column_text(statement, 1) {
                        nameS = String(cString:n)
                    }
                    var greekS = ""
                    if let g = sqlite3_column_text(statement, 6) {
                        greekS = String(cString:g)
                    }
                    ret.append (
                        (hr:Int(sqlite3_column_int(statement, 0)),
                        name:nameS,
                        ra:sqlite3_column_double(statement,2),
                        dec:sqlite3_column_double(statement,3),
                        mag:sqlite3_column_double(statement,4),
                        common:commonS,
                        greek:greekS)
                    )
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return ret;
    }

    func bigDipper() -> [(hr:Int,name:String,ra:Double,dec:Double,mag:Double,common:String,greek:String)] {
        _ = open()
        let arr =  queryForStars(sql: "select hr,name,ra,dec,magnitude,commonName from stars where commonName in ('ALKAID','MIZAR','MEGREZ','DUBHE','MERAK','PHAD','ALIOTH');")
        close()
        return arr
    }
    
    

    func query(sql:String) -> [(hr:String,ra:Double,dec:Double, magnitude:Double,spectralType:String, commonName:String, num:String,greek:String,constellation:String,spec:String,lumin:String,parsecs:String,ly:String,xs:Double,ys:Double,zs:Double)] {
        
        var ret = [(hr:String,ra:Double,dec:Double, magnitude:Double,spectralType:String, commonName:String, num:String,greek:String,constellation:String,spec:String,lumin:String,parsecs:String,ly:String,xs:Double,ys:Double,zs:Double)]()
        
        var statement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \(sql)")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    var hrS = ""
                    if let h = sqlite3_column_text(statement, 0) {
                        hrS = String(cString:h)
                    }
                    var spectralTypeS = ""
                    if let n = sqlite3_column_text(statement, 4) {
                        spectralTypeS = String(cString:n)
                    }
                    var commonS = ""
                    if let s = sqlite3_column_text(statement, 5) {
                        commonS = String(cString:s)
                    }
                    var numS = ""
                    if let s = sqlite3_column_text(statement, 6) {
                        numS = String(cString:s)
                    }
                    var greekS = ""
                    if let g = sqlite3_column_text(statement,7) {
                        greekS = String(cString:g)
                    }
                    var constS = ""
                    if let g = sqlite3_column_text(statement, 8) {
                        constS = String(cString:g)
                    }
                    var specS = ""
                    if let g = sqlite3_column_text(statement, 9) {
                        specS = String(cString:g)
                    }
                    var luminS = ""
                    if let g = sqlite3_column_text(statement, 10) {
                        luminS = String(cString:g)
                    }
                    var parsecsS = ""
                    if let g = sqlite3_column_text(statement, 11) {
                        parsecsS = String(cString:g)
                    }
                    var lyS = ""
                    if let g = sqlite3_column_text(statement, 12) {
                        lyS = String(cString:g)
                    }
                    ret.append ((
                        hr:hrS,
                        ra:sqlite3_column_double(statement,1),
                        dec:sqlite3_column_double(statement,2),
                        magnitude:sqlite3_column_double(statement,3),
                        spectralType:spectralTypeS,
                        commonName:commonS,
                        num:numS,
                        greek:greekS,
                        constellation:constS,
                        spec:specS,
                        lumin:luminS,
                        parsecs:parsecsS,
                        ly:lyS,
                        xs:sqlite3_column_double(statement,13),
                        ys:sqlite3_column_double(statement,14),
                        zs:sqlite3_column_double(statement,15)
                    ))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        return ret;
    }
    


}
