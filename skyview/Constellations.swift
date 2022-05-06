//
//  Constellations.swift
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

import simd

class Constellations {
    

    
    // this takes the output of getConstellationPointsXYZ() to pairs of points in XYZ
    // used for making the database table EndPoints  It's used by
    // makeConstellationLines()
    func getConstellationPointsXYZ0(_ name:String) -> [(name:String, first:(x:Double,y:Double,z:Double),second:(x:Double,y:Double,z:Double))]? {
        
        var points = [(name:String,first:(x:Double,y:Double,z:Double),second:(x:Double,y:Double,z:Double))]()
        
        func raDecToXYZ(ra:Double, dec:Double) -> (x:Double,y:Double,z:Double) {
            let raRadians = ra * Double.pi/180.0
            let decRadians = dec * Double.pi/180.0
            let X = cos(raRadians) * cos(decRadians)
            let Y = sin(raRadians) * cos(decRadians)
            let Z = sin(decRadians)
            return (X,Y,Z)
        }
        
        // this is how to generate new rows for the Endpoint table...
        // Switch to getConstellationPoints() then
        // copy output from the console to a csv file.
        // Then update Endpoints with the new stuff:
        //      sqlite3 bsc5.db
        //      delete from Endpoints where name = (const name)
        //      .separator ","
        //      .import (new CSV file) Endpoints
        if let pairs = getConstellationPoints(name) {  // pairs in ra,dec
            for val in pairs {
                let first = raDecToXYZ(ra:val.0, dec:val.1)
                let second = raDecToXYZ(ra:val.2, dec:val.3)
                print("'",name,"',",first.x,",",first.y,",",first.z,",",second.x,",",second.y,",",second.z)
                points.append((name,first,second))
            }
        }
        return points
    }
    
    // called by getConstellationPointsXYZ0()
    //    used for making the database table EndPoints
    func getConstellationPoints(_ name:String) -> [(Double,Double,Double,Double)]? {
          var pairs:[(String,String)]? = nil
        let namel = name.lowercased()
        switch(namel) {
        case "and":
            pairs =  [
                ("Gam1","Bet"),
                ("Bet","Del"),
                ("Del","Alp"),
                // minor lines
//                ("Bet","Pi"),
//                ("Pi","Del"),
//                ("Del","Eps"),
//                ("Iot","Pi"),
//                ("Iot","Omi"),
//            ("Bet","Mu"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "ant":
            pairs =  [
                ("Iot","Alp"),
            ("Gam","Alp"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "aps":
            pairs =  [
                ("Gam","Bet"),
                ("Bet","Del"),
                ("Alp","Del"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "aql":
            pairs =  [
                    ("Alp","Bet"),
                    ("Alp","Gam"),
                ("Del","Gam"),
                ("Del","Zet"),
                ("Zet","Eps"),

                ("Del","Eta"),
                ("Eta","The"),
                ("Del","Lam"),
                ("Iot","Lam"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "aqr":
            pairs =  [
                ("Alp","Bet"),
                ("Eps","Mu"),
                ("Mu","Bet"),
                ("Alp","Bet"),
                ("Alp","Pi"),
                ("Zet2","Pi"),
                ("Zet2","Gam"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "ara":
            pairs =  [
                ("Alp","Bet"),
                ("Bet","Gam"),
                ("Gam","Del"),
                ("Eta","Del"),
                ("Eta","Zet"),
                ("Zet","Eps"),
                ("Eps","Alp"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "ari":
            pairs =  [
                ("Alp","Bet"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "aur":
            pairs =  [
                ("Alp","Bet"),
                ("Bet","The"),
                //                ("Iot","Omi"),
                ("Alp","Eps"),
                ("Alp","Eta"),
                ("Eps","Eps"),
                ("Eta","Iot"),
                ("Eps","Zet")
            ]
            var arr = pairsToPoints(pairs:pairs!,name:namel)
            // beta tau to eta
            // beta tau to the
            let catalog = BrightStarCatalog.shared
            _ = catalog.open()
            if let starBeta = catalog.lookupBayerName(greek:"Bet", constellation:"tau") {
                if let star = catalog.lookupBayerName(greek:"Iot", constellation:"aur") {
                    arr.append ((starBeta.ra,starBeta.dec,star.ra,star.dec))
                }
                if let star = catalog.lookupBayerName(greek:"The", constellation:"aur") {
                    arr.append ((starBeta.ra,starBeta.dec,star.ra,star.dec))
                }
            }
            catalog.close()
            return arr
        case "boo":
            pairs = [
                ("Bet","Gam"),
                ("Gam","Rho"),
                ("Rho","Alp"),
                ("Alp","Eps"),
                ("Alp","Eta"),
                ("Eps","Del"),
                ("Del","Bet"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cae":
            pairs = [
                ("Bet","Gam"),
                ("Bet","Alp"),
                ("Del","Alp"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cam":
            pairs = [
                ("Gam","Alp"),
            ]

//            ("Del","Gam"),
//               ("Gam","Alp"),
//               ("Alp","Bet")
//               ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cas":
            pairs = [
                ("Eps","Del"),
                ("Gam","Del"),
                ("Gam","Alp"),
                ("Alp","Bet")
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cen":
            pairs = [
                ("Alp","Bet"),
            ("Eps","Bet"),
            ("Eps","Gam"),
            ("Sig","Gam"),
            ("Sig","Rho"),
            ("Omi1","Rho"),

            ("Sig","Del"),
            ("Del","Pi"),

            ("Zet","Mu"),
            ("Nu","Mu"),
            ("The","Nu"),
            ("The","Psi"),
            ("Xi","Psi"),
            ("Xi","Phi"),

            ("Nu1","Phi"),
            ("Nu2","Phi"),
            ("Nu2","Zet"),

            ("Phi","Eta"),
            ("Kap","Eta"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cep":
            pairs =  [
               ("Alp","Bet"),
               ("Bet","Gam"),
               ("Gam","Iot"),
               ("Alp","Mu"),
               ("Eps","Mu"),
               ("Eps","Zet"),
               ("Zet","Del"),
               ("Del","Iot"),
               ("Bet","Iot"),
               
               ("Alp","Eta"),
               ("Eta","The")
               ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cet":
            pairs =  [
                ("Alp","Lam"),
                ("Mu","Lam"),
                ("Alp","Gam"),
                ("Del","Gam"),
                ("Del","Omi"),
                ("Gam","Nu"),
                ("Nu","Xi 2"),
                ("Mu","Xi 2"),
                ("Tau","Bet"),
                ("Tau","Zet"),
                ("Zet","The"),
                ("Eta","The"),
                ("Eta","Iot"),
                ("Bet","Iot"),
                ("Zet","Omi"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cha":
            pairs =  [
                ("Alp","Gam"),
                ("Eps","Gam"),
                ("Eps","Bet"),
                ("Bet","Del"),
                ("Alp","Gam"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cir":
            pairs =  [
                ("Alp","The"),
                ("The","Bet"),
                ("Alp","Gam"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "col":     // columba
            pairs =  [
                ("Eps","Alp"),
                ("Alp","Bet"),
                ("Bet","Gam"),
                ("Del","Gam"),
                ("Bet","Eta"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "com":
            pairs =  [
                ("Eps","Alp"),
                ("Alp","Bet"),
                ("Bet","Gam"),
                ("Del","Gam"),
                ("Bet","Eta"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "cma":
            pairs =  [
                ("Alp","Bet"),
                ("Alp","Iot"),
                ("Iot","Gam"),
                ("Gam","The"),
                ("Alp","Pi"),
                ("Del","Sig"),
                ("Sig","Omi1"),
                ("Del","Omi2"),
                ("Del","Eta"),
                ("Pi","Omi2"),
                ("Bet","Nu 2"),
                ("Omi1","Nu 2"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cmi":
                pairs =  [
                 ("Alp","Bet"),
                ]
                return pairsToPoints(pairs:pairs!,name:namel)
        case "cnc":
            pairs = [
                ("Del","Alp"),
                ("Del","Bet"),
                ("Del","Gam"),
                ("Gam","Iot"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
            
        case "crb":
            pairs =  [
                ("The","Bet"),
                ("Alp","Bet"),
                ("Alp","Gam"),
                ("Del","Gam"),
                 ("Del","Eps"),

                   ]
                return pairsToPoints(pairs:pairs!,name:namel)
            
        case "crv":
            pairs =  [
                ("Alp","Eps"),
                ("Eps","Gam"),
                ("Del","Gam"),
                ("Del","Bet"),
                ("Eps","Bet"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
    case "crt":
        pairs =  [
            ("Alp","Bet"),
            ("Gam","Bet"),
            ("Del","Gam"),
            ("Del","Alp"),

            ("Del","Eps"),
            ("Eps","The"),

            ("Gam","Zet"),
            ("Zet","Eta"),
        ]
        return pairsToPoints(pairs:pairs!,name:namel)
            
        case "cru":
            pairs =  [
               ("Alp","Gam"),
               ("Del","Bet"),
               ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "cyg":
            pairs =  [
               ("Alp","Gam"),
               ("Del","Gam"),
               ("Del","The"),
               ("Gam","Eps"),

               ("The","Iot2"),
               ("Kap","Iot2"),
               ("Eta","Gam"),
               ("Bet1","Eta"),
               ("Zet","Eps"),
               ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "cvn":
            pairs = [
                ("Bet","Alp"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "del":
            pairs = [
                ("Gam2","Alp"),
            ("Gam2","Del"),
            ("Bet","Del"),
            ("Bet","Zet"),
            ("Zet","Alp"),
            ("Zet","Eps"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "dor":
            pairs = [
                ("Gam","Alp"),
                ("Alp","Zet"),
                ("Bet","Zet"),
                ("Bet","Alp"),
                ("Bet","Del"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "dra":
            pairs = [
                ("Gam","Bet"),
            ("Del","Sig"),
            ("Del","Phi"),
            ("Xi","Del"),
            ("Eps","Sig"),
            ("Pi","Psi"),
            ("Nu 1","Psi"),
            ("Nu 1","Bet"),
            ("Zet","Eta"),
            ("Eta","The"),
            ("The","Iot"),
            ("Iot","Alp"),
            ("Alp","Kap"),
            ("Kap","Lam"),
            ("Zet","Ome"),
            ("Zet","Phi"),
            ("Chi","Phi"),
            ("Xi","Gam"),
            ("Xi","Nu 2"),

            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "eri":
            pairs =  [
                ("Bet","Ome"),
            ("Mu","Ome"),
            ("Mu","Nu"),
            ("Omi2","Nu"),
            ("Omi2","Gam"),

            ("Gam","Pi"),
            ("Pi","Del"),
            ("Del","Eps"),
            ("Eps","Eta"),

            ("Tau1","Tau2"),
            ("Tau3","Tau2"),
            ("Tau3","Tau4"),
            ("Tau5","Tau4"),
            ("Tau5","Tau6"),
            ("Tau7","Tau7"),
            ("Tau7","Tau8"),
            ("Tau19","Tau8"),
            
            ("The","Iot"),
            ("Kap","Iot"),
            ("Kap","Xi"),
            ("Alp","Xi"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "for":      // fornax
            pairs =  [
                ("Bet","Nu"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "gem":
            pairs =  [
                ("Alp","Tau"),
                ("Tau","The"),
                ("Tau","Eps"),
                ("Eps","Mu"),
                ("Eta","Mu"),
                ("Eps","Nu"),
                
                ("Iot","Tau"),
                ("Bet","Ups"),
                ("Iot","Ups"),
                ("Kap","Ups"),
                ("Del","Ups"),
                ("Del","Lam"),
                ("Del","Zet"),
                ("Gam","Zet"),
                ("Lam","Xi"),
            ]
            // Mu to 1
            return pairsToPoints(pairs:pairs!,name:namel)

        case "gru":          // grus
            pairs =  [
                ("Zet","Eps"),
            ("Bet","Eps"),
            ("Bet","Alp"),
            ("Bet","Del2"),
            ("Mu2","Del2"),
            ("Mu2","Lam"),
            ("Gam","Lam"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "her":
            pairs =  [
                ("Alp1","Bet"),
            ("Alp1","Del"),
            ("Pi","Eps"),
            ("Del","Eps"),
            ("Zet","Eps"),
            ("Zet","Bet"),
            ("Zet","Eta"),
            ("Pi","Eta"),
            ("Pi","Rho"),
            ("The","Rho"),
            ("The","Iot"),
            ("Eta","Sig"),
            ("Sig","Tau"),
            ("Tau","Phi"),
            ("Bet","Gam"),
            ("Ome","Gam"),
            ]
            // add 28
            return pairsToPoints(pairs:pairs!,name:namel)
        case "hor":      // horologium
            pairs =  [
               ("Bet","Mu"),
               ("Eta","Mu"),
               ("Eta","Zet"),
               ("Zet","Iot"),
               ("Zet","Alp"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
            
        case "hya":  // hydra
            pairs =  [
                ("Pi","Gam"),
                ("Bet","Gam"),
                ("Bet","Xi"),
                // Xi to beta,crater
                // alpha crater to nu
                
                ("Nu","Mu"),
                ("Mu","Lam"),
                ("Lam","Alp"),
                ("Alp","Iot"),
                ("Iot","The"),
                ("The","Eta"),
                
                ("Eps","Eta"),
                ("Eps","Del"),
                ("Del","Sig"),
                ("Eta","Sig"),
                ("Eta","Rho"),
            ]
            var list = pairsToPoints(pairs:pairs!,name:namel)

            let catalog = BrightStarCatalog.shared
            _ = catalog.open()
            if let betaCrater = catalog.lookupBayerName(greek:"Bet", constellation:"Crt") {
                if let xiHya = catalog.lookupBayerName(greek:"Xi", constellation:"Hya") {
                    list.append ((xiHya.ra,xiHya.dec,betaCrater.ra,betaCrater.dec))
                }
            }
            if let alphaCrater = catalog.lookupBayerName(greek:"Alp", constellation:"Crt") {
                if let nuHya = catalog.lookupBayerName(greek:"Nu", constellation:"Hya") {
                    list.append ((nuHya.ra,nuHya.dec,alphaCrater.ra,alphaCrater.dec))
                }
            }
            catalog.close()
            return list

        case "hyi": // hydrus
            pairs =  [
                ("Alp","Bet"),
                ("Gam","Bet"),
                ("Alp","Gam"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "ind":            // indus
            pairs =  [
                ("Alp","Eta"),
                ("Eta","Bet"),
                ("Bet","Del"),
                ("The","Del"),
                ("The","Alp"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "lmi":       // leo minor
            pairs =  [
                        // todo
               ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "lac":
            pairs =  [
               ("Alp","Bet"),
               ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "leo":
            pairs =  [
               ("Bet","Del"),
               ("Del","The"),
               ("The","Bet"),
               ("The","Eta"),
               ("Alp","Eta"),
               ("Del","Gam1"),
               ("Gam1","Eta"),
               ("Zet","Gam1"),
               ("Zet","Mu"),
               ("Eps","Mu"),
               ]
            return pairsToPoints(pairs:pairs!,name:namel)
            
        case "lep":
            pairs =  [
               ("Alp","Bet"),
               ("Gam","Bet"),
               ("Gam","Del"),
               ("The","Del"),
               ("Eps","Bet"),
               ("Eps","Mu"),
               ("Alp","Mu"),
               ("Alp","Zet"),
               ("Eta","Zet"),
               ("Eta","The"),
               ("Mu","Lam"),
               ("Mu","Kap"),
               ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "lib":
            pairs = [
                ("Alp1","Bet"),
            ("Gam","Bet"),
            ("Alp1","Gam"),
            ("Alp1","Sig"),
            ("Ups","Gam"),
            ("Ups","Tau"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "lup":      // lupus
            pairs = [
                //todo
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
            
  //          "lyn",
            
        case "lyr":
            pairs = [
                ("Alp","Eps1"),
                ("Eps1","Zet1"),
                ("Alp","Zet1"),
                ("Del2","Zet1"),
                ("Bet","Zet1"),
                ("Gam","Bet"),
                ("Gam","Del2"),
            ]
            var arr = pairsToPoints(pairs:pairs!,name:namel)
            
            let catalog = BrightStarCatalog.shared
            _ = catalog.open()
            if let star23 = catalog.lookupConstellationNumber(number:"23", constellation:"lyr") {
                //("Alp","23"),
                if let star = catalog.lookupBayerName(greek:"Alp", constellation:"lyr") {
                    arr.append ((star23.ra,star23.dec,star.ra,star.dec))
                }
                //("Omi","23"),
                if let star = catalog.lookupBayerName(greek:"Omi", constellation:"lyr") {
                    arr.append ((star23.ra,star23.dec,star.ra,star.dec))
                }
                //("Ups","23"),
                if let star = catalog.lookupBayerName(greek:"Ups", constellation:"lyr") {
                    arr.append ((star23.ra,star23.dec,star.ra,star.dec))
                }
            }
            catalog.close()
            return arr
        case "men":       //mensa
             pairs = [
                ("Alp","Bet"),
            ("Gamma","Bet"),
            ("Alp","Gamma"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "mic":  // microscopium
            pairs = [
            ("Alp","Gamma"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "mon":    // monceros
            pairs = [
            ("Beta","Delta"),  // partial
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "mus":  // musca
            pairs = [
            ("Beta","Delta"),  // partial
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "nor":  // norma
            pairs = [
                ("Beta","Delta"),  // partial
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "oct":  // norma
            pairs = [
                ("Beta","Delta"),  // partial
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "oph":
            pairs = [
                ("Gam","Nu"),
                ("Bet","Alp"),
                ("Alp","Kap"),
            ("Kap","Lam"),
            ("Del","Lam"),
            ("Del","Eps"),
//            ("Nu","Eps"),

            ("Zet","Eps"),
            ("Zet","Kap"),
            
            ("Zet","Eta"),
            ("Bet","Eta"),
            ("Bet","Gam"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "ori":
            pairs = [
                ("Gam","Pi 3"),
                ("Pi 2","Pi 1"),
                ("Pi 3","Pi 2"),
                ("Pi 4","Pi 3"),
                ("Pi 5","Pi 4"),
                ("Pi 4","Pi 5"),
                ("Pi 5","Pi 6"),
                ("Lam","Alp"),
                ("Alp","Gam"),
                ("Lam","Gam"),
                ("Alp","Zet"),
                ("Eps","Zet"),
                ("Eps","Del"),
                ("Kap","Sig"),
                ("Eta","Del"),
                ("Eta","Bet"),
                ("Gam","Del"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
//            "pav",

        case "peg":
            pairs = [
                ("Gam","Alp"),
                ("Alp","Bet"),
                ("Bet","Eta"),
                ("Eta","Pi 1"),
                //            ("Alp","Sig"),
                ("Alp","Xi"),
                ("Xi ","Zet"),
                ("Zet","The"),
                ("The","Eps"),
                ("Bet","Mu"),
                ("Mu","Lam"),
                ("Lam","Iot"),
                ("Iot","Kap"),
                //            ("Eps","Del1"),
                //            ("Gam","Del1")
            ]
            var arr = pairsToPoints(pairs:pairs!,name:namel)
            let catalog = BrightStarCatalog()
            _ = catalog.open()
            if let starAlpha = catalog.lookupBayerName(greek:"Alp", constellation:"and") {
                if let star = catalog.lookupBayerName(greek:"Gam", constellation:"peg") {
                    arr.append((starAlpha.ra,starAlpha.dec,star.ra,star.dec))
                }
                if let star = catalog.lookupBayerName(greek:"Bet", constellation:"peg") {
                    arr.append((starAlpha.ra,starAlpha.dec,star.ra,star.dec))
                }
            }
            catalog.close()
            return arr
            
        case "per":
            pairs =  [
                ("Eps","Psi"),
                ("Psi","ALp"),
                ("Alp","Gam"),
                ("Gam","Eta"),
                ("Eta","Tau"),
                ("Tau","Iot"),
                ("Kap","Iot"),
                ("Kap","Bet"),
                ("Eps","Bet"),
                ("Eps","Xi"),
                ("Zet","Xi"),
                ("Zet","Omi"),
                ("Alp","Iot"),
                ("Bet","Rho"),
                ("Gam","Tau"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
//            "phe",
//            "pic",
//            "psa",
        case "psc":              // pisces
            pairs = [
                ("Tau","Phi"),
                ("Phi","Ups"),
                ("Ups","Tau"),
                
                ("Phi","Rho"),
                ("Eta","Rho"),
                ("Eta","Omi"),
                ("Alp","Omi"),

                ("Alp","Nu"),
                ("Nu","Mu"),
                ("Mu","Eps"),
                ("Eps","Del"),
                ("Del","Ome"),
                ("Ome","Iot"),
                
                ("Iot","The"),
                ("The","Gam"),
                ("Gam","Kap"),
                ("Kap","Lam"),
                ("Lam","Iot"),
            ]
//            print("------")
            return  pairsToPoints(pairs:pairs!,name:namel)
//            "pup",
//            "pyx",
//            "ret",
        case  "scl":
            pairs = [
                ("Alp","Iot"),
                ("Iot","Del"),
                ("Del","Gam"),
                ("Gam","Bet"),
            ]
            return  pairsToPoints(pairs:pairs!,name:namel)
        case "sco":
            pairs =  [
                ("Bet1","Del"),
                ("Del","Pi"),
                ("Del","Rho"),
                ("Del","Sig"),
                ("Alp","Sig"),
                ("Alp","Tau"),
                ("Eps","Tau"),
                ("Eps","Mu 1"),
                ("Zet1","Mu 1"),
                ("Zet1","Eta"),
                ("Eta","The"),
                ("The","Iot1"),
                ("Kap","Iot1"),
                ("Kap","Ups"),
            ]
            return  pairsToPoints(pairs:pairs!,name:namel)
            
        case "sct":  // scutum
            pairs =  [
                ("Alp","Bet"),
            ("Del","Bet"),
            ("Del","Gam"),
            ("Alp","Gam"),
            ]
            return  pairsToPoints(pairs:pairs!,name:namel)

        case "ser":
            pairs =  [
                ("Iot","Kap"),
                ("Gam","Kap"),
                ("Gam","Bet"),
                ("Iot","Bet"),
                ("Del","Bet"),
                ("Del","Alp"),
                ("Eps","Alp"),
                ("Eps","Ome"),
                ("Mu","Ome"),
                ]
                return  pairsToPoints(pairs:pairs!,name:namel)
//            "sex",
//            "sge",

        case "sgr":
            pairs =  [
                ("Tau","Sig"),
                ("Sig","Phi"),
            ("Sig","Lam"),
            ("Del","Lam"),

            ("Del","Phi"),
            ("Del","Gam2"),
            ("Gam2","Eps"),
            ("Del","Eps"),
            ("Zet","Eps"),
            ("Zet","Tau"),
            ("Zet","Phi"),
            ]
            let arr = pairsToPoints(pairs:pairs!,name:namel)
            return arr

        case "tau":
            pairs =  [
                ("Alp","The2"),
                ("The2","Gam"),
                ("Gam","Lam"),
            ("Omi","Lam"),
            ("Eps","Del1"),
            ("Del1","Gam"),
            
            ("Zet","Alp"),
            ("Eps","Bet"),
            ]
            let arr = pairsToPoints(pairs:pairs!,name:namel)
            return arr
        case "tel":          // telescopium
            pairs = [
            ("Alp","Zet"),
            ]
           return pairsToPoints(pairs:pairs!,name:namel)

        case "tra":           // triangulum australe
             pairs = [
             ("Alp","Bet"),
             ("Gam","Bet"),
             ("Alp","Gam"),
             ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "tri":
            pairs = [
            ("Bet","Del"),
            ("Alp","Bet")
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "tuc":   // tucana
            pairs = [
            ("Alp","Del"), // partial
            ("Del","Eps")
            ]
            return pairsToPoints(pairs:pairs!,name:namel)

        case "uma":
            pairs = [
            ("Eta","Zet"),
            ("Zet","Eps"),
            ("Del","Eps"),
            ("Del","Alp"),
            ("Alp","Bet"),
            ("Bet","Gam"),
            ("Del","Gam"),
            ("Xi","Gam"),
            //("Xi","Psi"),
            ("Chi","Psi"),
            ("Mu","Psi"),
            ("Mu","Lam"),
            ("Bet","Ups"),
            ("Omi","Ups"),
            ("The","Kap"),
            ("The","Ups"),
            ]
            //("Alp","23"),
            //("Omi","23"),
            //("Ups","23"),
            return pairsToPoints(pairs:pairs!,name:namel)
        case "umi":     // ursa minor
            pairs = [
            ("Alp","Del"),
            ("Del","Eps"),
            ("Eps","Zet"),
            ("Zet","Bet"),
            ("Bet","Gam"),
            ("Gam","Eta"),
            ("Zet","Eta"),
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "vel":
            pairs = [
            ("Mu","Phi"),
            ("Kap","Phi"),
            ("Kap","Del"),
            ("Del","Gam2"),
            ("Lam","Gam2"),
            ("Lam","Psi"),
            ("Psi","Lam"),
            ("Del","Gam")
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "vir":
            pairs = [
            ("Alp","The"),
            ("The","Gam"),
            ("Del","Gam"),
            ("Del","Eps"),

            ("Gam","Zet"),
            ("Gam","Eta"),
            ("Eta","Bet"),
            ("Bet","Nu"),
            ("Nu","Omi"),
            ("Omi","Eta"),
            ("Zet","Tau"),
            ("Zet","Iot"),
            ("Iot","Mu")
            ]
            var arr = pairsToPoints(pairs:pairs!,name:namel)
            let catalog = BrightStarCatalog.shared
            _ = catalog.open()
            if let starTau = catalog.lookupBayerName(greek:"Tau", constellation:"vir") {
                if let star = catalog.lookupConstellationNumber(number:"109", constellation:"vir") {
                    arr.append((starTau.ra,starTau.dec,star.ra,star.dec))
                }
            }
            catalog.close()
            return arr
        case "vol":
            pairs = [
            ("Alp","Eps"),
            ("Gam","Eps"),
            ("Gam","Del"),
            ("Del","Eps"),
            ("Bet","Eps"),
            ("Bet","Alp")
            ]
            return pairsToPoints(pairs:pairs!,name:namel)
        case "vul":
            // alp to 23
            var arr = [(Double,Double,Double,Double)]()
            let catalog = BrightStarCatalog.shared
            _ = catalog.open()
            if let star1 = catalog.lookupBayerName(greek:"Alp", constellation:"vul") {
                if let star2 = catalog.lookupConstellationNumber(number:"23", constellation:"vul") {
                    arr.append((star1.ra,star1.dec,star2.ra,star2.dec))
                }
            }
            catalog.close()
            return arr
        default:
            break
        }
        return nil
    }
    
    // used for making the database table EndPoints
    func pairsToPoints(pairs:[(String,String)],name:String) -> [(Double,Double,Double,Double)] {
        let catalog = BrightStarCatalog.shared
        var raDecEndPoints = [(Double,Double,Double,Double)]()
        for (first,second) in pairs {
            if let f = catalog.lookupBayerName(greek: first, constellation: name) {
                if let s = catalog.lookupBayerName(greek: second, constellation: name) {                raDecEndPoints.append((f.ra,f.dec,s.ra,s.dec))
                }
                else {
                    print("could not look up \(name)  second:\(second)")
                }
            }
            else {
                print("could not look up \(name)  first:\(first)")
            }
        }
        return raDecEndPoints
    }
    
}
