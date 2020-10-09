//
//  SettingsVC.swift
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

class SettingsVC: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {
    var appDelegate:AppDelegate? = nil

    // Surveys that are marked "lite" in this list:
    // http://aladin.unistra.fr/hips/list
    let surveys = [
        //        – Optical –
        (id:"P/DSS2/color",desc:"Digitized Sky Survey (Color)",type:"Visual", url:"https://archive.eso.org/dss/dss"),
        (id:"P/DSS2/red",desc:"Digitized Sky Survey (Red)",type:"Visual",url:"https://archive.eso.org/dss/dss"),
        (id:"P/DSS2/blue",desc:"Digitized Sky Survey (Blue)",type:"Visual",url:"https://archive.eso.org/dss/dss"),
        
        (id:"P/SDSS9/color",desc:"SLOAN Digitized Sky Survey", type:"Visual",url:"https://www.sdss.org"),
        
        //        – Infrared –
        (id:"P/2MASS/color",desc:"The Two Micron All Sky Survey", type:"Infrared",url:"https://www.sdss.org"),
        
// not infrared?
//        (id:"P/AKARI/FIS/Color",desc:"AKARI Far Infrared", type:"Far Infrared",url:""),



        (id:"P/DECaLS/DR3/color",desc:"Dark Energy Survey DR3", type:"", url:""),
// not responding
//        (id:"P/DECaPS/DR1/color",desc:"Dark Energy Survey DR1", type:"", url:""),
        
        (id:"P/Fermi/color",desc:"Fermi Gamma Ray", type:"Gamma", url:""),
        (id:"P/Finkbeiner",desc:"Finkbeiner Halpha Composite", type:"Halpha", url:""),
        (id:"P/GALEXGR6/AIS/color",desc:"GALEX Allsky Imaging Survey", type:"Ultraviolet", url:""),
        (id:"P/IRIS/color",desc:"IRIS", type:"", url:""),

        (id:"P/Mellinger/color",desc:"Mellinger Color Optical Survey", type:"Visual", url:""),
        
        (id:"P/PanSTARRS/DR1/color-z-zg-g",desc:"PanSTARRS color-z-zg-g", type:"", url:""),
        (id:"P/PanSTARRS/DR1/g",desc:"PanSTARRS g", type:"", url:""),
        (id:"P/PanSTARRS/DR1/z",desc:"PanSTARRS z", type:"Visual", url:""),
        
        (id:"P/SPITZER/color",desc:"SPITZER/color", type:"Infrared", url:""),
        (id:"P/allWISE/color",desc:"allWISE/color", type:"Infrared", url:""),
        (id:"P/GLIMPSE360",desc:"GLIMPSE360", type:"Infrared", url:""),
        (id: "P/VTSS/Ha", desc:"VTSS/Ha", type:"Ha", url:"http://www1.phys.vt.edu/~halpha/"),
        
// not responding
    //    (id: "P/SWIFT_BAT_FLUX",desc:"Swift-BAT X-ray", type:"Hard X Ray", url:""),
    //    (id: "P/BAT/100-150keV", desc:"P/BAT/100-150keV X-ray", type:"Hard X-ray", url:""),
    //    (id: "P/XMM/PN/color", desc:"P/XMM/PN/color", type:"", url:"")
    ]
        
    @IBOutlet weak var gridLinesSwitch: UISwitch!
    @IBOutlet weak var constellationLinesSwitch: UISwitch!
    @IBOutlet weak var constellationNamesSwitch: UISwitch!
    @IBOutlet weak var bullsEyeSwitch: UISwitch!
    @IBOutlet weak var bayerNamesSwitch: UISwitch!
    @IBOutlet weak var commonNamesSwitch: UISwitch!
    @IBOutlet weak var aladinFieldOfView: UISwitch!
    @IBOutlet weak var plusSignSwtich: UISwitch!
    @IBOutlet weak var messierSwitch: UISwitch!
    
    @IBOutlet weak var surveyPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.settingsVC = self
        surveyPicker.dataSource = self
        surveyPicker.delegate = self
        // select the survey
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let settings = appDelegate?.settings {
            gridLinesSwitch.isOn = settings.drawGrid
            constellationLinesSwitch.isOn = settings.drawConstellationLines
            constellationNamesSwitch.isOn = settings.drawConstellationNames
            bullsEyeSwitch.isOn = settings.drawFOV
            bayerNamesSwitch.isOn = settings.drawBayer
            commonNamesSwitch.isOn = settings.drawCommonNames
            aladinFieldOfView.isOn = settings.drawAladin
            messierSwitch.isOn = settings.drawMessier
            plusSignSwtich.isOn = settings.drawPlusSigns
            
            for i in 0..<surveys.count {
                if surveys[i].id == settings.survey {
                    surveyPicker.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
//        appDelegate?.heartBeat!.stop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let appDelegate = appDelegate {
            if let aladinVC = appDelegate.aladinVC {
                aladinVC.webView.setNeedsDisplay()
            }
            if let skyViewVC = appDelegate.skyViewVC {
                skyViewVC.skyView.setNeedsDisplay()
            }
        }

    }
    
    @IBAction func clickGridLines(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawGrid = !settings.drawGrid
            gridLinesSwitch.isOn = settings.drawGrid
        }
    }
    
    @IBAction func clcikConstellatoinLines(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawConstellationLines = !settings.drawConstellationLines
            constellationLinesSwitch.isOn = settings.drawConstellationLines
        }
    }
    
    @IBAction func clickConstellationNames(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawConstellationNames = !settings.drawConstellationNames
            constellationNamesSwitch.isOn = settings.drawConstellationNames
        }
    }
    
    @IBAction func clickBayerNames(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawBayer = !settings.drawBayer
            bayerNamesSwitch.isOn = settings.drawBayer
        }
    }
    
    // along the way the bullseye became the telescope FOV
    @IBAction func clickBullsEye(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawFOV = !settings.drawFOV
            bullsEyeSwitch.isOn = settings.drawFOV
        }
    }
    
    @IBAction func clickCommonNames(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawCommonNames = !settings.drawCommonNames
            commonNamesSwitch.isOn = settings.drawCommonNames
        }
    }
    
    @IBAction func clickAladinFieldOfView(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawAladin  = !settings.drawAladin
            aladinFieldOfView.isOn = settings.drawAladin
        }
    }
    
    @IBAction func clickMessier(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawMessier  = !settings.drawMessier
            messierSwitch.isOn = settings.drawMessier
        }
    }
    
    @IBAction func clickPlusSign(_ sender: Any) {
        if let settings = appDelegate?.settings {
            settings.drawPlusSigns  = !settings.drawPlusSigns
            plusSignSwtich.isOn = settings.drawPlusSigns
        }
    }
    
    // MARK:  UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let settings = appDelegate?.settings {
            if row < surveys.count {
                settings.survey = surveys[row].id
            }
        }
    }

    
    // MARK:  UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return surveys.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
  //      print("component = \(row)")
         let font:UIFont = UIFont(name: "Helvetica Neue", size: 18.0)!
        return row < surveys.count ? NSAttributedString(string: surveys[row].desc, attributes: [
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : font, NSAttributedString.Key.foregroundColor : UIColor.white]) : nil
    }

}
