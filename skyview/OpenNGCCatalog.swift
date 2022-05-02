//
//  OpenNGCCatalog.swift
//  Created by Tod Landis on 4/6/22.
//

import Foundation
import SQLite3

/*
 
 This is an interface to the OpenNGC data.  The steps to create OpenNGC.db were:
        download https://github.com/mattiaverga/OpenNGC/NGC.csv    
        run "sqlite3 OpenNGC.db < create.sql" in the same folder
 OpenNGC is subject to the Creative Commons Attribution Share Alike 4.0 International:
        https://github.com/mattiaverga/OpenNGC/LICENSE
 
 - Name: Object name composed by catalog + number
     NGC: New General Catalogue
     IC: Index Catalogue
     
 - Type: Object type
     *: Star
     **: Double star
     *Ass: Association of stars
     OCl: Open Cluster
     GCl: Globular Cluster
     Cl+N: Star cluster + Nebula
 
     G: Galaxy
     GPair: Galaxy Pair
     GTrpl: Galaxy Triplet
     GGroup: Group of galaxies
     PN: Planetary Nebula
     HII: HII Ionized region
     DrkN: Dark Nebula
     EmN: Emission Nebula
     Neb: Nebula
     RfN: Reflection Nebula
     SNR: Supernova remnant
     Nova: Nova star
     NonEx: Nonexistent object
     Dup: Duplicated object (see NGC or IC columns to find the master object)
     Other: Other classification (see object notes)
     
 - RA: Right Ascension in J2000 Epoch - decimal degrees

 - Dec: Declination in J2000 Epoch - decimal degrees

 - Const: Constellation where the object is located
     Serpens is expressed as 'Se1' for Serpens Caput and 'Se2' for Serpens Caudi

 - MajAx: Major axis, expressed in arcmin

 - MinAx: Minor axis, expressed in arcmin
 
 - PosAng: Major axis position angle (North Eastwards)

 - B-Mag: Apparent total magnitude in B filter

 - V-Mag: Apparent total magnitude in V filter

 - J-Mag: Apparent total magnitude in J filter

 - H-Mag: Apparent total magnitude in H filter

 - K-Mag: Apparent total magnitude in K filter

 - SurfBr (only Galaxies): Mean surface brigthness within 25 mag isophot (B-band), expressed in mag/arcsec2

 - Hubble (only Galaxies): Morphological type (for galaxies)

 - Cstar U-Mag (only Planetary Nebulae): Apparent magnitude of central star in U filter

 - Cstar B-Mag (only Planetary Nebulae): Apparent magnitude of central star in B filter

 - Cstar V-Mag (only Planetary Nebulae): Apparent magnitude of central star in V filter

 - M: cross reference Messier number

 - NGC: other NGC identification, if the object is listed twice in the catalog

 - IC: cross reference IC number, if the object is also listed with that identification

 - Cstar Names (only Planetary Nebulae): central star identifications

 - Identifiers: cross reference with other catalogs

 - Common names: Common names of the object if any

 - NED Notes: notes about object exported from NED

 - OpenNGC Notes: notes about the object data from OpenNGC catalog
 */
class OpenNGCCatalog:ObservableObject {
    
    static let shared: OpenNGCCatalog = {
        let instance = OpenNGCCatalog()
        return instance
    }()

    var databasePath:String
    var database: OpaquePointer? = nil


    init() {

        // uncomment these lines to fill in ra,dec,x,y,z in a copy of the db
        // in Downloads (this only needs to be done once per download)
//        databasePath = "/Users/todlandis/Downloads/OpenNGC.db"
//        print("Updating OpenNGC in Downloads...")
//        updateRaDecAndXYZ()
//        print("Done!")
        
        
        if let url = Bundle.main.url(forResource: "OpenNGC", withExtension: "db") {
            databasePath = url.path
        }
        else {
            print("ERROR Unable to find OpenNGC.db")
            databasePath = "ERROR"
        }
    }
    
    // execute an update
    func execute(_ sql:String) {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            print("ERROR preparing \"\(sql)\"")
            sqlError();
            return
        }
        guard sqlite3_step(statement) == SQLITE_DONE else {
            print("ERROR stepping \(sql)")
            sqlError();
            return
        }
        sqlite3_finalize(statement)
    }
    
    func stringFrom(_ text: UnsafePointer<UInt8>!) -> String {
        if text != nil {
            return String.init(cString:text)
        }
        else {
            return "NULL"
        }
    }
    
    // majorAxis s/b expressed in arcmin
    func getGalaxies(majorAxis:Double = 4.0) -> [NGCObject] {
        //G: Galaxy
        //GPair: Galaxy Pair
        //GTrpl: Galaxy Triplet
        //GGroup: Group of galaxies

        return getNGCObjects("WHERE (Type = 'G' OR Type = 'GPair' OR Type = 'GTrpl' OR Type = 'GGroup') AND majAx > \(majorAxis)")
    }
    
    func getSuperNovaRemnants() -> [NGCObject] {
            return getNGCObjects("WHERE Type = 'SNR'")
    }

    func getGlobularClusters() -> [NGCObject] {
            return getNGCObjects("WHERE Type = 'GCl'")
    }

    func getOpenClusters() -> [NGCObject] {
            return getNGCObjects("WHERE Type = 'OCl'")
    }

    func getDarkNebulas() -> [NGCObject] {
            return getNGCObjects("WHERE Type = 'DrkN'")
    }

    func getNebulas() -> [NGCObject] {
//            Cl+N: Star cluster + Nebula
//            PN: Planetary Nebula
//            EmN: Emission Nebula
//            Neb: Nebula
//            RfN: Reflection Nebula

            return getNGCObjects("WHERE Type = 'Cl+N' OR Type = 'EmN' OR Type = 'Neb' OR Type = 'RfN'")
    }

    func getHIIRegions() -> [NGCObject] {
            return getNGCObjects("WHERE Type = 'HII'")
    }

    func getNovas() -> [NGCObject] {
            return getNGCObjects("WHERE Type = 'Nova'")
    }

    func getBinaries() -> [NGCObject] {
            return getNGCObjects("WHERE Type = '**'")
    }

    func getNGCObjects(_ sql:String) -> [NGCObject] { //[(name:String,x:Double,y:Double,z:Double,hubble:String,majAx:Double)] {
        
        var ret = [NGCObject]()
        if (sqlite3_open(databasePath, &database) != SQLITE_OK) {
            print("ERROR:  unable to open database")
            database = nil;
            sqlError();
            return ret
        }
        var statement: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database, "SELECT name,x,y,z,type,hubble,majAx,m FROM OpenNGC  ".appending(sql), -1, &statement, nil) != SQLITE_OK) {
            print("ERROR preparing \"\(sql)\"")
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    let name = stringFrom(sqlite3_column_text(statement, 0))
                    let x = Double(sqlite3_column_double(statement, 1))
                    let y = Double(sqlite3_column_double(statement, 2))
                    let z = Double(sqlite3_column_double(statement, 3))
                    let type = stringFrom(sqlite3_column_text(statement, 4))
                    let hubble = stringFrom(sqlite3_column_text(statement, 5))
                    let majAx =  Double(sqlite3_column_double(statement, 6))
                    let m =      stringFrom(sqlite3_column_text(statement, 7))
                    ret.append(NGCObject(name:name,x:x,y:y,z:z,type:type,hubble:hubble,majAx:majAx,m:m))
                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        sqlite3_close(database)
        database = nil
        return ret;
    }
//    
//    func queryForGalaxies() -> [NGCObject] {
//        //G: Galaxy
//        //GPair: Galaxy Pair
//        //GTrpl: Galaxy Triplet
//        //GGroup: Group of galaxies
//
//        return queryForNGCObjects(whereSQL: "WHERE Type = 'G' OR Type = 'GPair' || Type = 'GTrpl' || Type = 'GGroup'")
//    }
//    
//    func queryForNGCObjects(whereSQL:String = "",orderSQL:String = "") -> [NGCObject] {
//        let selectSQL = "select name,ra,dec,Type, const,MajAx,MinAx,PosAng,Hubble,M from OpenNGC"
//        let sql = selectSQL + " " + whereSQL + " " + orderSQL;
//        return queryForNGCObjects(sql)
//    }
//    
//    // 'sql' must query for all the fields to fill in an NGCObject
//    // see queryForNGCObjects()
//    func queryForNGCObjects(_ sql:String) -> [NGCObject] {
//        
//        var ret = [NGCObject]()
//        if (sqlite3_open(databasePath, &database) != SQLITE_OK) {
//            print("ERROR:  unable to open database")
//            database = nil;
//            sqlError();
//            return ret
//        }
//        var statement: OpaquePointer? = nil
//        
//        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) != SQLITE_OK) {
//            print("ERROR preparing \"\(sql)\"")
//            sqlError();
//        }
//        else {
//            var more:Bool = true
//            repeat {
//                let state = sqlite3_step(statement)
//                if (state == SQLITE_ROW) {
//                    let name = stringFrom(sqlite3_column_text(statement, 0))
//                    let ra = Double(sqlite3_column_double(statement, 1))
//                    let dec = Double(sqlite3_column_double(statement, 2))
//                    let type = stringFrom(sqlite3_column_text(statement, 3))
//                    let const = stringFrom(sqlite3_column_text(statement, 4))
//                    let majAx = Double(sqlite3_column_double(statement, 5))
//                    let minAx = Double(sqlite3_column_double(statement, 6))
//                    let posAng = Double(sqlite3_column_double(statement, 7))
//                    let hubble = stringFrom(sqlite3_column_text(statement, 8))
//                    let m = stringFrom(sqlite3_column_text(statement, 9))
//
//                    ret.append(NGCObject(name:name,ra:ra,dec:dec,type:type,const:const,majAx:majAx,minAx:minAx,posAng:posAng,hubble:hubble,m:m))
//                }
//                else {
//                    more = false
//                }
//            } while(more)
//        }
//        sqlite3_finalize(statement);
//        sqlite3_close(database)
//        database = nil
//        return ret;
//    }
    
                                  
    func sqlError() {
        print("SQL ERROR");
    }
    
    // calculate ra,dec columns from raHMS,decDMS
    // this only needs to be done once
    func updateRaDecAndXYZ() {
        if (sqlite3_open(databasePath, &database) != SQLITE_OK) {
            print("ERROR:  unable to open database")
            database = nil;
            sqlError();
            return
        }
        
        var statement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database, "select name,raHMS,decDMS from OpenNGC", -1, &statement, nil) != SQLITE_OK) {
            sqlError();
        }
        else {
            var more:Bool = true
            repeat {
                let state = sqlite3_step(statement)
                if (state == SQLITE_ROW) {
                    var name = ""
                    if let tmp = sqlite3_column_text(statement, 0) {
                        name = String(cString:tmp)
                    }

                    // the abbrev is in 1
                    var raHMS = ""
                    if let tmp = sqlite3_column_text(statement, 1) {
                        raHMS = String(cString:tmp)
                    }

                    var decDMS = ""
                    if let tmp = sqlite3_column_text(statement, 2) {
                        decDMS = String(cString:tmp)
                    }

                    if let ra = Convert.hmsToDecimalDegrees(raHMS,separator:":"),let dec = Convert.dmsToDecimalDegrees(decDMS,separator:":") {
                    //    print("\(m)\t\(ra)\t\(dec)")
                        
                        let raRadians = ra * Double.pi/180.0
                        let decRadians = dec * Double.pi/180.0
                        let X = cos(raRadians) * cos(decRadians)
                        let Y = sin(raRadians) * cos(decRadians)
                        let Z = sin(decRadians)

                        execute("UPDATE OpenNGC SET ra = \(ra), dec = \(dec), x = \(X), y = \(Y), z = \(Z) WHERE Name = '\(name)'")
                    }
                    else {
                        print("ERROR")
                    }

                }
                else {
                    more = false
                }
            } while(more)
        }
        sqlite3_finalize(statement);
        sqlite3_close(database)
    }
}
