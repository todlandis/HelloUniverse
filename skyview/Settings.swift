//
//  Settings.swift
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

class Setting {
    enum SettingType {
       case boolType
    }
    
    var type:SettingType
    var name:String
    var isOn:Bool
    
    init(_ n:String,_ isOn:Bool) {
        self.type = .boolType
        self.name = n
        self.isOn = isOn
    }
}
 

class Settings {
    var list:[Setting] = []
    
    var drawGrid =               Setting("Draw Gridlines", false)
    var drawConstellationLines = Setting("Constellation Lines", true)
    var drawConstellationNames = Setting("Constellation Names", true)
    
    var drawCommonNames =  Setting("Star Names", false)
    var drawHRNames =      Setting("Star HR Names", false)
    var drawMagnitude =    Setting("Star Magnitudes", false)
    var drawBayer =        Setting("Star Greek Letters", false)
 
    var drawMessier =      Setting("Messier Objects", false)
    var drawSharpless =    Setting("Sharpless Objects", false) // not in UI
    
    var drawGalaxies =     Setting("NGC Galaxies",true)
    var drawSNR =          Setting("NGC Super Nova Remnants",false)
    var drawGlobular =     Setting("NGC Globular Clusters",false)
    var drawOpenClusters = Setting("NGC Open Clusters",false)
    var drawNebulas =      Setting("NGC Nebulas",false)
    var drawHIIRegions =   Setting("NGC HII Regions",false)
    var drawDarkNebulas =  Setting("NGC Dark Nebulas",false)
    var drawNovas =        Setting("NGC Novas",false)
    var drawBinaries =     Setting("NGC Binaries",false)

    var drawFOV =          Setting("Telescope FOV",false)  // not in UI
    var drawAladin =       Setting("Aladin Frame", true)
    var drawCenterPlus =   Setting("CenterPlus Sign", false)

    init() {
        list.append(drawGrid)
        list.append(drawConstellationLines)
        list.append(drawConstellationNames)

        list.append(drawCommonNames)
        list.append(drawHRNames)
        list.append(drawMagnitude)
        list.append(drawBayer)
        list.append(drawMessier)
        
        list.append(drawGalaxies)
        list.append(drawSNR)
        list.append(drawGlobular)
        list.append(drawOpenClusters)
        list.append(drawNebulas)
        list.append(drawHIIRegions)
        list.append(drawDarkNebulas)
        list.append(drawNovas)
        list.append(drawBinaries)

       //  list.append(drawFOV)
        list.append(drawAladin)
        list.append(drawCenterPlus)
    }

   // var drawGrid =     false

    var decimalFormat = false
    
    
    
    var drawSpectralType =    false    // ui does not surface this yet
    var drawParsecs =         false    // ui does not surface this yet


    var drawBullsEye =     false       // ui does not surface this yet
    
    var messierLabelSize =       CGFloat(18.0)
    var constellationLabelSize = CGFloat(18.0)
    var starNameLabelSize =      CGFloat(14.0)
    
    var starColor =     UIColor.white

    var messierColor = TangoColors.TANGOORANGE
    
    var previousSurvey:Int = 0
    var currentSurvey:Int = 0 {
        willSet {
            previousSurvey = currentSurvey
        }
    }
    
//    var previousSurvey:String = "P/DSS2/color"
//    var survey:String = "P/DSS2/color" {
//        willSet {
////            previousSurvey = survey
//        }
//    }
    
    // Surveys that are marked "lite" in this list:
    // http://aladin.unistra.fr/hips/list
    let surveys = [

        (id:"P/DSS2/color",desc:"1:Digitized Sky Survey (Color)",type:"Visual", url:"https://archive.eso.org/dss/dss"),
        (id:"P/HST/WideV",desc:"Hubble",type:"",url:""),
        (id:"P/2MASS/color",desc:"2:Two Micron All Sky Survey", type:"Near Infrared",url:"https://www.sdss.org"),
        //        The Two Micron All Sky Survey - J-H-K bands (2MASS color)
        //        2MASS color J (1.23um), H (1.66um), K (2.16um)
        // blue at 1.2 microns, green at 1.6 microns microns, and red at 2.2 microns
        
        // band covering the galaxy
        (id:"P/allWISE/color",desc:"3:allWISE/color", type:"Infrared", url:""),
        // from list:
        //         3.4, 4.6, 12, and 22 um (W1, W2, W3, W4)
        //        hips_rgb_red         = w4 [102.0 151.0 200.0 Log]
        //        hips_rgb_green       = w2 [0.0 80.0 160.0 Log]
        //        hips_rgb_blue        = w1 [0.0 200.0 400.0 Log]

        // not working, seems to show 1
        (id:"P/AKARI/FIS/Color",desc:"4:AKARI Far Infrared", type:"Far Infrared",url:""),
        // from list:
        // 90 um (WIDE-S), 140um (WIDE-L),and 160um (N160)
        //        hips_rgb_red         = WideLHiPS [0.0 250.0 500.0 Log]
        //        hips_rgb_green       = WideSHiPS [-1.5 91.75 185.0 Log]
        //        hips_rgb_blue        = N60HiPS [-1.5 69.25 140.0 Log]

        (id:"P/SPITZER/color",desc:"5:SPITZER/color", type:"Infrared", url:""),

        // band covering the galaxy
        (id:"P/GLIMPSE360",desc:"6:GLIMPSE360", type:"Infrared", url:""),
        //  not sure, but might be 3.6 μm for blue, 4.5 μm for green and 8.0 μm for red

        (id:"P/DSS2/blue",desc:"7:Digitized Sky Survey (Blue)",type:"Visual",url:"https://archive.eso.org/dss/dss"),
//        obs_regime           = Optical
//        em_min               = 4.68e-7
//        em_max               = 4.91e-7
        
        (id:"P/SDSS9/color",desc:"8:SLOAN Digitized Sky Survey", type:"Visual",url:"https://www.sdss.org"),
        
        (id:"P/Finkbeiner",desc:"9:Finkbeiner Halpha Composite", type:"Gas", url:""),
     
        (id:"P/GALEXGR6/AIS/color",desc:"10:GALEX Allsky Imaging Survey", type:"Ultraviolet", url:""),
        //GALEX has performed sky surveys with different depth and coverage in two ultraviolet bands, FUV (1344-1786 A) and NUV (1771-2831 A).
        //hips_rgb_red         = AIS-NDHiPS [9.908E-4 0.149936878125 0.2943 Sqrt]
        //hips_rgb_blue        = AIS-FDHiPS [0.0 0.02466879665851593 0.04933759331703186 Sqrt]

        (id:"P/IRIS/color",desc:"11:IRIS", type:"", url:""),
        
        (id:"P/Mellinger/color",desc:"12:Mellinger Color Optical Survey", type:"Visual", url:""),
        
        (id:"P/PanSTARRS/DR1/color-z-zg-g",desc:"13:PanSTARRS color-z-zg-g", type:"", url:""),
        (id:"P/PanSTARRS/DR1/g",desc:"14:PanSTARRS g", type:"", url:""),

        // not working, seems to show 1
        (id:"P/PanSTARRS/DR1/z",desc:"15:PanSTARRS z", type:"Visual", url:""),
        
        (id:"P/DSS2/red",desc:"16:Digitized Sky Survey (Red)",type:"Visual",url:"https://archive.eso.org/dss/dss"),
        //        obs_regime           = Optical
        //        em_min               = 6.4e-7
        //        em_max               = 6.58e-7
        //
        
        (id:"P/DECaLS/DR3/color",desc:"17:Dark Energy Survey DECaLS/DR3", type:"", url:""),
        // northern hemisphere in three optical bands (g,r,z) and four infrared bands
        
        // works for Sgr A
        (id:"P/Fermi/color",desc:"18:Fermi Gamma Ray", type:"Gamma", url:""),
        //hips_rgb_red         = 300-1000MeVALLSKY~1 [0.0 10.0 20.0 Sqrt]
        //hips_rgb_green       = 1-3GeVALLSKY~1 [0.0 5.0 10.0 Sqrt]
        //hips_rgb_blue        = 3-300GeVALLSKY [0.0 2.0 4.0 Sqrt]

        // not working, seems to show 1
        (id: "P/VTSS/Ha", desc:"19:VTSS/Ha", type:"Ha", url:"http://www1.phys.vt.edu/~halpha/"),

        // not working, seems to show 1
        (id: "P/SWIFT_BAT_FLUX",desc:"20:Swift-BAT X-ray", type:"Hard X Ray", url:""),
        // RGB images are created from Swift-BAT data, where R is 14-24 keV, G is 24-50 keV and B is 50-194 keV.

        // not working, seems to show 1
        (id: "P/BAT/100-150keV", desc:"21:P/BAT/100-150keV X-ray", type:"Hard X-ray", url:""),

        (id: "P/XMM/PN/color", desc:"23:P/XMM/PN/color", type:"", url:""),
        // False color X-ray images (Red=0.5-1 Green=1-2 Blue=2-4.5 Kev ),
        
        // worked for Sgr A
        (id:"P/DECaPS/DR1/color",desc:"24:Dark Energy Survey DR1", type:"", url:"")

    ]
    
    func chooseSurvey(survey:String) {
        var i = 0
        while i < surveys.count {
            if surveys[i].id == survey {
                break
            }
            i = i + 1
        }
        if i == surveys.count {
            print("a survey in a URL wasn't found:  \(survey)")
            currentSurvey = 0
//            self.survey = surveys[0].desc
            return
        }
        currentSurvey = i
//        self.survey = survey
    }
}
